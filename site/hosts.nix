{
  root = { role = "storage-root"; };
  app01 = { role = "app-server"; identity.yubikey = "yk-app01"; address.storage = "10.10.0.11"; };
  app02 = { role = "app-server"; identity.yubikey = "yk-app02"; address.storage = "10.10.0.12"; };
  laptop01 = { role = "laptop"; identity.yubikey = "yk-laptop01"; address.storage = "10.10.0.21"; };
  desktop01 = { role = "desktop"; identity.yubikey = "yk-desktop01"; address.storage = "10.10.0.31"; boot.ipxe = true; };
}
