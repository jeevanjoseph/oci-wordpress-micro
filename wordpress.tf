# module "wordpress" {
#   source                = "./modules/wordpress"
#   availability_domain   = var.availablity_domain_name
#   compartment_ocid      = var.compartment_ocid
#   image_id              = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
#   shape                 = var.node_shape
#   label_prefix          = var.label_prefix
#   display_name          = "wordpress"
#   subnet_id             = oci_core_subnet.public.id
#   ssh_authorized_keys   = tls_private_key.public_private_key_pair.public_key_openssh 
#   ssh_private_key       = tls_private_key.public_private_key_pair.private_key_pem
#   mds_ip                = module.mds-instance.private_ip
#   admin_password        = var.admin_password
#   admin_username        = var.admin_username
#   wp_schema             = var.wp_schema
#   wp_name               = var.wp_name
#   wp_password           = var.wp_password
#   wp_plugins            = split(",", var.wp_plugins)
#   wp_themes             = split(",", var.wp_themes)
#   wp_site_title         = var.wp_site_title
#   wp_site_admin_user    = var.wp_site_admin_user
#   wp_site_admin_pass    = var.wp_site_admin_pass
#   wp_site_admin_email   = var.wp_site_admin_email
# }

data "template_file" "wordpress-docker-compose" {
  template = file("${path.module}/scripts/wordpress.yaml")

  vars = {
    public_key_openssh = tls_private_key.public_private_key_pair.public_key_openssh, 
    admin_password = var.admin_password,
    wp_password = var.wp_password
    wp_site_url         = oci_core_public_ip.WordPress_public_ip.ip_address
  }  
}


resource "oci_core_instance" "WordPress" {
  availability_domain = local.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "wordpress"
  shape               = var.node_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    display_name     = "primaryvnic"
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = local.images[var.region]
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
    user_data           = base64encode(templatefile("./scripts/setup-docker.yaml",{
                            public_key_openssh = tls_private_key.public_private_key_pair.public_key_openssh, 
                            admin_password = var.admin_password,
                            wp_password = var.wp_password }))
    
  }

}

data "oci_core_vnic_attachments" "WordPress_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain_name
  instance_id         = oci_core_instance.WordPress.id
}

data "oci_core_vnic" "WordPress_vnic1" {
  vnic_id = data.oci_core_vnic_attachments.WordPress_vnics.vnic_attachments[0]["vnic_id"]
}

data "oci_core_private_ips" "WordPress_private_ips1" {
  vnic_id = data.oci_core_vnic.WordPress_vnic1.id
}

resource "oci_core_public_ip" "WordPress_public_ip" {
  compartment_id = var.compartment_ocid
  display_name   = "WordPress_public_ip"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.WordPress_private_ips1.private_ips[0]["id"]
}

resource "null_resource" "WordPress_provisioner" {
  depends_on = [oci_core_instance.WordPress, oci_core_public_ip.WordPress_public_ip]

  provisioner "file" {
    content     = data.template_file.wordpress-docker-compose.rendered
    destination = "/home/opc/wordpress.yaml"

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
  }

  provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
   
    inline = [
       "while [ ! -f /tmp/cloud-init-complete ]; do sleep 2; done",
       "docker-compose -f /home/opc/wordpress.yaml up -d"
    ]

   }
}



locals  {
  images = {
    ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaab5hueid2p7xxvvl3yr7j3spxjs3yhxmyo7jh6i5dx3kra3zpsigq"
    ap-hyderabad-1 = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaalqmxvz5snhts6ozkowksdv3zwdz4jwpsl27q2cfkudxjsaayabyq"
    ap-melbourne-1 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaayvmfy6zxbai74w2jgmhhhapq2agwx3gaintugyjlw2k5r2ripwmq"
    ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa7oaxxmtsvkk5vc53bryvxlxqn7lb5bjemkhbw5newm7oulnzquwq"
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaarnsy2bkeenaygvmkdpckjetjy4kfwvne7vyrqecjriqvw7b7xwa"
    ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaybdqvkups2oaz5vn4fk4ck3flwstbpjhz25pfmz4duzja3huvzra"
    ap-sydney-1 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaakfscrhq4nmvzs3n6tt6hhe6fjb63ui5g3fphkhjhwntz4cqpwquq"
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaazitsi3g3qp4h3ww37vigol7qynaulhltpk6z6oub5d7dqjhznh4a"
    ca-montreal-1 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaicftckdcfi2ubahzl2maf7dfqltbr5cr757n3hxgtunzvmw7tt3a"
    ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaafrnmvd4uopmz6vj36rqpifvigzb3khhrcjvendo6bf5aqaghsoia"
    eu-amsterdam-1 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa2tz7mwkc5upj3mpm4ofayqzypqtdwwznl3tf4vi6cimskadwggsa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa5w2lrmsn6wpjn7fbqv55curiarwsryqhoj4dw5hsixrl37hrinja"
    eu-zurich-1 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaq34sljrwq6ifcdfwlmewg3cfm3sael5r4hgflny6zdjb3xc7jkaq"
    me-dubai-1 = "ocid1.image.oc1.me-dubai-1.aaaaaaaa2mkz4tjbo6rtyxvhfakkvvwg56mhqlu42xlakq23xwgotdmrmvwa"
    me-jeddah-1 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaawnlta4ua2sytgjsdd7asdb4naqbgpbiycpcmicdpi3jufh2qajuq"
    sa-santiago-1 = "ocid1.image.oc1.sa-santiago-1.aaaaaaaaiy6oob3asj3vq2rqiti7ud6ifbvt5uwylsemgdkcslqndlfvwnja"
    sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa426ghk7ku5ysklb5wrbd6g5gvf24k5bndxpvdn6uy44wme2n4asq"
    uk-cardiff-1 = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaayiibl7nrv23nljwbleu6aictqagqrxrllrfyzjcds5s2t3xmrw4q"
    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaauqkqbhkk3ganayt7xutwvy3jjznmenf2tnrjzyu32wzssaw6fwbq"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaqdc7jslbtue7abhwvxaq3ihvazfvihhs2rwk2mvciv36v7ux5sda"
    us-gov-ashburn-1 = "ocid1.image.oc3.us-gov-ashburn-1.aaaaaaaarlix5x3p27nv7jp6iwefpekn7ui5ogqkcj3jspis2ygxfjjh72cq"
    us-gov-chicago-1 = "ocid1.image.oc3.us-gov-chicago-1.aaaaaaaak3jk4wkn3g4vhkrjcgg6v7ixxrmcsxja5bjsfnuoj5bsfaodq2fq"
    us-gov-phoenix-1 = "ocid1.image.oc3.us-gov-phoenix-1.aaaaaaaa4wktlpy2o2pxcmkbxbbx4wppwd3dxplsez6npskttyykobr554ca"
    us-langley-1 = "ocid1.image.oc2.us-langley-1.aaaaaaaahkwvd2ix7nfz3nykrteghnio6hzrzrxudvwmu47q3swl2eglxrja"
    us-luke-1 = "ocid1.image.oc2.us-luke-1.aaaaaaaa4zoccgg4qj4uilfyhiwcbupz66fejyyogwbuazyuuennxjtwlvba"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaaptdwhdot3iosccxikn3oqb3l2qew7c5mcryixlulpn4diszgncfq"
    us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaag2fam5xawz7t3ad5u3mzxdhglxeldohlijdsjfaielqluysrc3ga"
  }

  availability_domain_name = data.oci_identity_availability_domains.ADs.availability_domains[length(data.oci_identity_availability_domains.ADs.availability_domains) - 1].name

  

}