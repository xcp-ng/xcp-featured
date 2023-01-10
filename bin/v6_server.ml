module S = V6_interface.RPC_API(Idl.Exn.GenServer ())

type context = unit

let editions =
  let open V6_interface in
  [
    {
      title = "xcp-ng";
      official_title = "xcp-ng";
      code = "xcp-ng";
      order = 100;
    };
  ] (* TODO: real editions *)

let unsupported_features =
  let open Features in
  [
    Corosync;
  ]

let supported_features =
  List.filter
    (fun feature -> not (List.mem feature unsupported_features))
    Features.all_features

type additional_feature =
  | VSwitch
  | Lab
  | Stage
  | StorageLink
  | StorageLinkSiteRecovery
  | WebSelfService
  | WebSelfServiceManager
  | HotfixApply
  | ExportResourceData
  | ReadCaching
  | CIFS
  | HealthCheck
  | XCM
  | VMMemoryIntrospection
  | BatchHotfixApply
  | ManagementOnVLAN
  | WSProxy
  | CloudManagement
  | VTPM

type orientation = Positive | Negative

let keys_of_additional_features =
  [
    VSwitch, (Negative, "restrict_vswitch_controller");
    Lab, (Negative, "restrict_lab");
    Stage, (Negative, "restrict_stage");
    StorageLink, (Negative, "restrict_storagelink");
    StorageLinkSiteRecovery, (Negative, "restrict_storagelink_site_recovery");
    WebSelfService, (Negative, "restrict_web_selfservice");
    WebSelfServiceManager, (Negative, "restrict_web_selfservice_manager");
    HotfixApply, (Negative, "restrict_hotfix_apply");
    ExportResourceData, (Negative, "restrict_export_resource_data");
    ReadCaching, (Negative, "restrict_read_caching");
    CIFS, (Negative, "restrict_cifs");
    HealthCheck, (Negative, "restrict_health_check");
    XCM, (Negative, "restrict_xcm");
    VMMemoryIntrospection, (Negative, "restrict_vm_memory_introspection");
    BatchHotfixApply, (Negative, "restrict_batch_hotfix_apply");
    ManagementOnVLAN, (Negative, "restrict_management_on_vlan");
    WSProxy, (Negative, "restrict_ws_proxy");
    CloudManagement, (Negative, "restrict_cloud_management");
    VTPM, (Negative, "restrict_vtpm");
  ]

let additional_params =
  (* Turn on all additional features. *)
  List.map
    (fun (_, (mode, feature_name)) ->
      (feature_name, string_of_bool (mode = Positive)))
    keys_of_additional_features

let apply_edition dbg edition params =
  let open V6_interface in
  {
    edition_name = "xcp-ng";
    xapi_params  = Features.to_assoc_list supported_features;
    additional_params = additional_params;
    experimental_features = [];
  }

let get_editions dbg = editions

let get_version dbg = Version.version
