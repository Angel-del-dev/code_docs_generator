<?php
/*
#vdocs
    @title Utils
    @description this is
    a
    proper
    description
    @subtitle Utils is a php class
#
*/
class Utils {
    /*
        #vdocs
            @subtitle __construct
            @code php __costruct():void
        #
    */
    public function __construct() {  }
    /*
        #vdocs
            @subtitle do_syscall
            @code php do_syscall(string $syscall):SysCallResult
        #
    */
    protected function do_syscall(string $syscall):SysCallResult {  }
    protected function read_file(string $route):void {  }
    protected function write_file(string $route, string $content) :void {  }
}