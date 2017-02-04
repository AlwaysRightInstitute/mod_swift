//
// Copyright (C) 2017 ZeeZide GmbH, All Rights Reserved
// Created by Helge Hess on 23/01/2017.
//

// This is the low-level entry point which sets up the Apache module.

import Apache2
import ApacheExpress

// This is our support object for ApacheExpress. Careful, this must be
// thread safe!
var apache : http_internal.ApacheServer! = nil

// The main entry point to generate ApacheExpress.http server callbacks
func ApacheExpressHandler(p: UnsafeMutablePointer<request_rec>?) -> Int32 {
  guard let apache = apache else { return DECLINED }
  return apache.handler(request: p)
}

func ApacheExpressPostConfig(pconf:  OpaquePointer?,
                             plog:   OpaquePointer?,
                             ptemp:  OpaquePointer?,
                             server: UnsafeMutablePointer<server_rec>?) -> Int32
{
  expressMain()
  return OK
}

fileprivate func register_hooks(pool: OpaquePointer?) {
  // this is to support ApacheExpress
  ap_hook_handler    (ApacheExpressHandler,    nil, nil, APR_HOOK_MIDDLE)
  ap_hook_post_config(ApacheExpressPostConfig, nil, nil, APR_HOOK_LAST)
}


// This is our module structure for Apache
var module = Apache2.module(name: "mods_todomvc")


// And `ApacheMain` is called by mod_swift to configure the module!
@_cdecl("ApacheMain")
public func ApacheMain(cmd: UnsafeMutablePointer<cmd_parms>) {
  // Setup module struct
  module.register_hooks = register_hooks
  
  // this is to support ApacheExpress
  apache = http_internal.ApacheServer(handle: cmd.pointee.server)
  
  // Let Apache know about our module
  let error = ap_add_loaded_module(&module, cmd.pointee.pool, "mods_todomvc")
  assert(error == nil, "Could not add Swift module!")
  
  // Note: we are lazy and do not register a cleanup
  ap_single_module_configure(cmd.pointee.pool, cmd.pointee.server, &module);
}
