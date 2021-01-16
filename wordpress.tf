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



resource "oci_core_instance" "service-instance" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[length(data.oci_identity_availability_domains.ADs.availability_domains) - 1].name
  compartment_id      = var.compartment_ocid
  display_name        = "wordpress"
  shape               = var.node_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    display_name     = "primaryvnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = local.images[var.region]
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
    user_data           = base64encode(templatefile("./scripts/setup-docker.yaml",{public_key_openssh = tls_private_key.public_private_key_pair.public_key_openssh }))
    # mount_target_ip     = data.oci_core_private_ip.mount_target_private_ip.ip_address
    # export_path         = oci_file_storage_export.tehama_room_fs_export.path
  }

}

locals  {
  images = {
    ap-mumbai-1    =	"ocid1.image.oc1.ap-mumbai-1.aaaaaaaanqnm77gq2dpmc2aih2ddlwlahuv2qwmokufb7zbi52v67pzkzycq"
    ap-seoul-1     =	"ocid1.image.oc1.ap-seoul-1.aaaaaaaav3lc5w7cvz5yr6hpjdubxupjeduzd5xvaroyhjg6vwqzsdvgus6q"
    ap-sydney-1    =	"ocid1.image.oc1.ap-sydney-1.aaaaaaaagtfumjxhosxrkgfci3dgwvsmp35ip5nbhy2rypxfh3rwtqsozkcq"
    ap-tokyo-1     =	"ocid1.image.oc1.ap-tokyo-1.aaaaaaaajousbvplzyrh727e3d4sb6bam5d2fomwhbtzatoun5sqcuvvfjnq"
    ca-montreal-1  =	"ocid1.image.oc1.ca-montreal-1.aaaaaaaamcmyjjewzrw7qz66lnsl4hf7mkaznw6iyrrdwc22z56vltj36mka"
    ca-toronto-1   =	"ocid1.image.oc1.ca-toronto-1.aaaaaaaavr35ze44lkflxffkhmt4xyamkfjpbjhsm5awxjwlnp3gpx7h7fgq"
    eu-frankfurt-1 =	"ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7gj6uot6tz6t34qjzvkldxtwse7gr5m7xvnh6xfm53ddxp3w37ja"
    eu-zurich-1    =	"ocid1.image.oc1.eu-zurich-1.aaaaaaaasl3mlhvgzhfglqqkwdbppmmgomkz6iyi42wjkceldqcpecg7jzgq"
    sa-saopaulo-1  =	"ocid1.image.oc1.sa-saopaulo-1.aaaaaaaawamujpmwxbjgrfeb66zpew5sgz4bimzb4wgcwhqdjyct53bucvoq"
    uk-london-1    =	"ocid1.image.oc1.uk-london-1.aaaaaaaa6trfxqtp5ib7yfgj725js3o6agntmv6vckarebsmacrhdxqojeya"
    us-ashburn-1   =	"ocid1.image.oc1.iad.aaaaaaaayuihpsm2nfkxztdkottbjtfjqhgod7hfuirt2rqlewxrmdlgg75q"
    us-langley-1   =	"ocid1.image.oc2.us-langley-1.aaaaaaaaazlspcasnl4ibjwu7g5ukiaqjp6xcbk5lqgtdsazd7v6evbkwxcq"
    us-luke-1      =	"ocid1.image.oc2.us-luke-1.aaaaaaaa73qnm5jktrwmkutf6iaigib4msieymk2s5r5iweq5yvqublgcx5q"
    us-phoenix-1   =	"ocid1.image.oc1.phx.aaaaaaaadtmpmfm77czi5ghi5zh7uvkguu6dsecsg7kuo3eigc5663und4za"
  }

  

}