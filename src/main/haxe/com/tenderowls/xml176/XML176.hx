package com.tenderowls.xml176;

import com.tenderowls.xml176.XML176Document;
import com.tenderowls.xml176.Tokenizer;

import haxe.io.BytesOutput;
import haxe.macro.Expr.Position;
import haxe.io.Output;
import haxe.io.Input;

class XML176 {

    /**
     *  Parse XML document from input. If you want to work
     *  with String just use haxe.io.StringInput.
     */
    public static function parse(source:Input, ?fileName:String):XML176Document {
        return null;
    }

    /**
     *  XML176 pretty printer.
     *  @param numSpaces number of spaces of indentation. Set -1 for tabs.
     */

    public static function print(document:XML176Document, ?numSpaces:Int):Output {
        return null;
    }
}