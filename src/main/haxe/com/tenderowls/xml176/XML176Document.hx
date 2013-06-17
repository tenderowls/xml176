package com.tenderowls.xml176;

import haxe.macro.Expr.Position;
import haxe.io.Input;

enum XML176Document {

    Node(name:QName, children:List<XML176Document>, pos:Position);
    Attr(name:QName, value:String, pos:Position);
    Comment(value:Input, pos:Position);
    CDATA(value:Input, pos:Position);
}

class QName {

    public var namespace(default, null):Namespace;
    public var name(default, null):String;

    public function new(namespace:Namespace, name:String) {
        this.namespace = namespace;
        this.name = name;
    }
}

class Namespace {

    public var prefix(default, null):Null<String>;
    public var uri(default, null):Null<String>;

    function new(?prefix:String, ?uri:String) {
        this.prefix = prefix;
        this.uri = uri;
    }
}

