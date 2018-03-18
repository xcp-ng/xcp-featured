type context = unit

let editions = ["xcp-ng", ("", "", 0)] (* TODO: real editions *)

let apply_edition _ dbg edition params =
  let open V6_interface in
  {
    edition = "xcp-ng";
    xapi_params  = Features.(to_assoc_list all_features);
    additional_params = [];
    experimental_features = [];
  }

let get_editions _ dbg = editions

let get_version _ dbg = Version.version
