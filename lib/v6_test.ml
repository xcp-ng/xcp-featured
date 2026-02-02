let features =
  Alcotest.testable Fmt.(Dump.list @@ Dump.pair string string) ( = )

let test_additional_features =
  let test () =
    let xapi_ones = Features.all_features |> Features.to_assoc_list in
    let xcpng_ones = Xcp_ng.V6.Additional.params in
    let in_both =
      List.filter (fun (k, _) -> List.mem_assoc k xapi_ones) xcpng_ones
    in
    Alcotest.(check features)
      "A base feature can't be present in the additional ones" [] in_both
  in
  ("Not present in xapi features", `Quick, test)

let feature_tests = ("Additional features", [test_additional_features])

let () = Alcotest.run "XCP-ng V6 library" [feature_tests]
