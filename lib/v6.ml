module L = Debug.Make (struct let name = __MODULE__ end)

let editions =
  let open V6_interface in
  [{title= "xcp-ng"; official_title= "xcp-ng"; code= "xcp-ng"; order= 100}]
(* TODO: real editions *)

let unsupported_features = Features.[Corosync]

let supported_features =
  List.filter
    (fun feature -> not (List.mem feature unsupported_features))
    Features.all_features

module Additional = struct
  type feature =
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
    | NRPE
  [@@deriving enum]

  (** Positive features are enabled when they are present (true), Negatives are
    disabled when present (true) *)
  type orientation = Positive | Negative [@@warning "-unused-constructor"]

  let enable = function Positive -> true | Negative -> false

  let props_of_feature = function
    | VSwitch ->
        ("restrict_vswitch_controller", Negative)
    | Lab ->
        ("restrict_lab", Negative)
    | Stage ->
        ("restrict_stage", Negative)
    | StorageLink ->
        ("restrict_storagelink", Negative)
    | StorageLinkSiteRecovery ->
        ("restrict_storagelink_site_recovery", Negative)
    | WebSelfService ->
        ("restrict_web_selfservice", Negative)
    | WebSelfServiceManager ->
        ("restrict_web_selfservice_manager", Negative)
    | HotfixApply ->
        ("restrict_hotfix_apply", Negative)
    | ExportResourceData ->
        ("restrict_export_resource_data", Negative)
    | ReadCaching ->
        ("restrict_read_caching", Negative)
    | CIFS ->
        ("restrict_cifs", Negative)
    | HealthCheck ->
        ("restrict_health_check", Negative)
    | XCM ->
        ("restrict_xcm", Negative)
    | VMMemoryIntrospection ->
        ("restrict_vm_memory_introspection", Negative)
    | BatchHotfixApply ->
        ("restrict_batch_hotfix_apply", Negative)
    | ManagementOnVLAN ->
        ("restrict_management_on_vlan", Negative)
    | WSProxy ->
        ("restrict_ws_proxy", Negative)
    | CloudManagement ->
        ("restrict_cloud_management", Negative)
    | NRPE ->
        ("restrict_nrpe", Negative)

  let all_features =
    let length = max_feature - min_feature + 1 in
    let start = min_feature in
    List.init length (fun i -> feature_of_enum (i + start) |> Option.get)

  let params =
    (* Turn on all additional features. *)
    all_features
    |> List.map (fun feature ->
        feature |> props_of_feature |> fun (feature_name, mode) ->
        (feature_name, string_of_bool (enable mode))
    )
end

let xapi_params = Features.to_assoc_list supported_features

module type Directory = sig val root : string end

(** Reads custom features from a directory, used to read experimental features,
    and is parametrised to be able to test the logic. *)
module Custom (D : Directory) : sig val list : unit -> (string * bool) list
end = struct
  let ( let* ) = Result.bind

  let dir_contents () =
    (try Unix.mkdir D.root 0o700 with Unix.(Unix_error (EEXIST, _, _)) -> ()) ;
    try Sys.readdir D.root |> Result.ok with e -> Error e

  let full_path feat = Filename.concat D.root feat

  let enabled_of_contents = function
    | "1" ->
        Ok true
    | "0" ->
        Ok false
    | v ->
        let msg =
          Printf.sprintf {|%s: "0" or "1" expected, found %s|} __FUNCTION__ v
        in
        Error (Invalid_argument msg)

  let props_of_feature name =
    try
      let contents = Xapi_stdext_unix.Unixext.string_of_file (full_path name) in
      let* enabled = enabled_of_contents contents in
      Ok (name, enabled)
    with e -> Error e

  let log_exn __LOC exn = L.info "%s: %s" __LOC (Printexc.to_string exn)

  let option_of f x =
    match f x with Ok v -> Some v | Error e -> log_exn __LOC__ e ; None

  let available () =
    let* feature_names = dir_contents () in
    feature_names
    |> Array.to_list
    |> List.filter_map (option_of props_of_feature)
    |> Result.ok

  let list () =
    let error e = log_exn __LOC__ e ; [] in
    Result.fold ~ok:Fun.id ~error (available ())
end

module Experimental = Custom (struct
  let root = "/etc/xcp/experimental-features.d"
end)

let apply_edition _dbg edition _params =
  {
    V6_interface.edition_name= edition
  ; xapi_params
  ; additional_params= Additional.params
  ; experimental_features= Experimental.list ()
  }

let get_editions _dbg = editions

(* This is supposed to be the burn-in date of the current XCP-ng release, or
   the Release To Manufacture date: the Date-Based Version. The commit that
   introduces it to xen-api uses "2009.0201" *)
let get_version _dbg = [("dbv", "2026.0202")]
