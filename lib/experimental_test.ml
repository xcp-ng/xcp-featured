(* This executable takes list of features as arguments, which can be enabled or
   disabled, prints them; then writes the features as files in a directory,
   reads the files using code from Xcp_ng.V6, and finally prints the resulting
   list from it. The lists should be equal. *)

let features_expected = ref []

let usage_msg =
  Printf.sprintf "%s: feature1=<true|false> [feature2=<true|false>] ..."
    Sys.executable_name

let spec = [ (* no special arguments *) ]

let anon_arg feature =
  let feature =
    match String.split_on_char '=' feature with
    | [name; enabled] ->
        (name, bool_of_string enabled)
    | _ ->
        raise (Invalid_argument feature)
  in
  features_expected := feature :: !features_expected

let with_random_temp_dir f =
  let random = Random.int64 Int64.max_int in
  let base = Filename.get_temp_dir_name () in
  let dir = Printf.sprintf "%s/features_%Lx" base random in

  Sys.mkdir dir 0o777 ;
  let finally () = try Sys.rmdir dir with _ -> () in

  Fun.protect ~finally (fun () -> f dir)

let print_features features =
  let sorted =
    List.fast_sort (fun (a, _) (b, _) -> String.compare a b) features
  in
  Printf.printf "[%s]\n"
    (String.concat "; "
       (List.map (fun (k, v) -> Printf.sprintf "%s: %b" k v) sorted)
    )

let ( let@ ) f x = f x

let ( // ) = Filename.concat

let contents_of_bool = function true -> "1" | false -> "0"

let write_features root =
  List.iter
    (fun (filename, enabled) ->
      try
        Xapi_stdext_unix.Unixext.write_string_to_file (root // filename)
          (contents_of_bool enabled)
      with _ -> ()
    )
    !features_expected

let delete_features root =
  List.iter
    (fun (filename, _) -> try Unix.unlink (root // filename) with _ -> ())
    !features_expected

let () =
  Arg.parse spec anon_arg usage_msg ;

  print_features !features_expected ;

  let@ root = with_random_temp_dir in

  write_features root ;

  let module TestFeatures = Xcp_ng.V6.Custom (struct let root = root end) in
  let features_actual = TestFeatures.list () in

  delete_features root ;

  print_features features_actual
