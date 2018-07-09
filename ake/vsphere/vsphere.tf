#===============================================================================
# vSphere Provider
#===============================================================================

provider "vsphere" {
  version        = "1.5.0"
  vsphere_server = "${var.vsphere_vcenter}"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"

  allow_unverified_ssl = "${var.vsphere_unverified_ssl}"
}

#===============================================================================
# vSphere Data
#===============================================================================

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_drs_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vm_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vm_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


# HAProxy template #
data "template_file" "haproxy" {
  template = "${file("templates/haproxy.tpl")}"

  vars {
    bind_ip = "${var.k8s_haproxy_ip}"
  }
}

# HAProxy server backend template #
data "template_file" "haproxy_backend" {
  count    = "${length(var.k8s_master_ips)}"
  template = "${file("templates/haproxy_backend.tpl")}"

  vars {
    prefix_server     = "${var.k8s_node_prefix}"
    backend_server_ip = "${lookup(var.k8s_master_ips, count.index)}"
    count             = "${count.index}"
  }
}


#===============================================================================
# vSphere Resources
#===============================================================================

# Create a virtual machine folder for the Kubernetes VMs #
resource "vsphere_folder" "folder" {
  path          = "${var.vm_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Create the Kubernetes master VMs #
resource "vsphere_virtual_machine" "master" {
  count            = "${length(var.k8s_master_ips)}"
  name             = "${var.k8s_node_prefix}-master-${count.index}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${vsphere_folder.folder.path}"

  num_cpus         = "${var.k8s_master_cpu}"
  memory           = "${var.k8s_master_ram}"
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"
  enable_disk_uuid = "true"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "${var.k8s_node_prefix}-master-${count.index}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = "${var.vm_linked_clone}"

    customize {
      linux_options {
        host_name = "${var.k8s_node_prefix}-${count.index}"
        domain    = "${var.k8s_domain}"
      }

      network_interface {
        ipv4_address = "${lookup(var.k8s_master_ips, count.index)}"
        ipv4_netmask = "${var.k8s_netmask}"
      }

      ipv4_gateway    = "${var.k8s_gateway}"
      dns_server_list = ["${var.k8s_dns}"]
    }
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.vm_user}"
      password = "${var.vm_password}"
    }

    inline = [
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^/#/' /etc/fstab",
    ]
  }

  depends_on = ["vsphere_virtual_machine.haproxy"]
}

# Create anti affinity rule for the Kubernetes master VMs #
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "master_anti_affinity_rule" {
  count               = "${var.vsphere_enable_anti_affinity == "true" ? 1 : 0}"
  name                = "${var.k8s_node_prefix}-master-anti-affinity-rule"
  compute_cluster_id  = "${data.vsphere_compute_cluster.cluster.id}"
  virtual_machine_ids = ["${vsphere_virtual_machine.master.*.id}"]
}

# Create the Kubernetes worker VMs #
resource "vsphere_virtual_machine" "worker" {
  count            = "${length(var.k8s_worker_ips)}"
  name             = "${var.k8s_node_prefix}-worker-${count.index}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${vsphere_folder.folder.path}"

  num_cpus         = "${var.k8s_worker_cpu}"
  memory           = "${var.k8s_worker_ram}"
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"
  enable_disk_uuid = "true"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "${var.k8s_node_prefix}-worker-${count.index}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = "${var.vm_linked_clone}"

    customize {
      linux_options {
        host_name = "${var.k8s_node_prefix}-worker-${count.index}"
        domain    = "${var.k8s_domain}"
      }

      network_interface {
        ipv4_address = "${lookup(var.k8s_worker_ips, count.index)}"
        ipv4_netmask = "${var.k8s_netmask}"
      }

      ipv4_gateway    = "${var.k8s_gateway}"
      dns_server_list = ["${var.k8s_dns}"]
    }
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.vm_user}"
      password = "${var.vm_password}"
    }

    inline = [
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^/#/' /etc/fstab",
    ]
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "sed 's/${var.k8s_node_prefix}-worker-[0-9]*$//' config/hosts.ini > config/hosts_remove_${count.index}.ini && sed -i '1 i\\${var.k8s_node_prefix}-worker-${count.index}\\ ansible_host=${self.default_ip_address}' config/hosts_remove_${count.index}.ini && sed -i 's/\\[kube-node\\]/\\[kube-node\\]\\n${var.k8s_node_prefix}-worker-${count.index}/' config/hosts_remove_${count.index}.ini"
  }

}

# Create the HAProxy load balancer VM #
resource "vsphere_virtual_machine" "haproxy" {
  name             = "${var.k8s_node_prefix}-haproxy"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${vsphere_folder.folder.path}"

  num_cpus = "${var.k8s_haproxy_cpu}"
  memory   = "${var.k8s_haproxy_ram}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "${var.k8s_node_prefix}-haproxy.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = "${var.vm_linked_clone}"

    customize {
      linux_options {
        host_name = "${var.k8s_node_prefix}-haproxy"
        domain    = "${var.k8s_domain}"
      }

      network_interface {
        ipv4_address = "${var.k8s_haproxy_ip}"
        ipv4_netmask = "${var.k8s_netmask}"
      }

      ipv4_gateway    = "${var.k8s_gateway}"
      dns_server_list = ["${var.k8s_dns}"]
    }
  }

  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "${var.vm_user}"
      password = "${var.vm_password}"
    }

    source      = "config/haproxy.cfg"
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.vm_user}"
      password = "${var.vm_password}"
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y haproxy",
      "sudo mv /tmp/haproxy.cfg /etc/haproxy",
      "sudo systemctl restart haproxy",
    ]
  }
}
