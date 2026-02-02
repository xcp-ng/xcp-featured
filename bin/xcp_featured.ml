let stop _ = exit 1

let handle_shutdown () =
  Sys.set_signal Sys.sigterm (Sys.Signal_handle stop) ;
  Sys.set_signal Sys.sigint (Sys.Signal_handle stop) ;
  Sys.set_signal Sys.sigpipe Sys.Signal_ignore

let start server =
  let (_ : Thread.t) =
    Thread.create (fun () -> Xcp_service.serve_forever server) ()
  in
  ()

let bind () =
  let open V6_server in
  S.apply_edition apply_edition ;
  S.get_editions get_editions ;
  S.get_version get_version

let () =
  bind () ;
  let server =
    Xcp_service.make ~path:!V6_interface.default_path
      ~queue_name:!V6_interface.queue_name
      ~rpc_fn:(Idl.Exn.server V6_server.S.implementation)
      ()
  in

  Debug.set_facility Syslog.Local5 ;
  Debug.disable "http" ;
  handle_shutdown () ;
  Debug.with_thread_associated "main" start server ;

  let module Daemon = Xapi_stdext_unix.Unixext.Daemon in
  ignore (Daemon.systemd_notify Daemon.State.Ready) ;

  while true do
    Thread.delay 300.
  done
