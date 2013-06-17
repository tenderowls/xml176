package com.tenderowls.xml176;

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

enum Token {

    Literal(value:String, position:Position);

    ExclamationMark(position:Position);
    QuestionMark(position:Position);
    OpenTag(position:Position);
    CloseTag(position:Position);
    SquareBracketLeft(position:Position);
    SquareBracketRight(position:Position);
    Minus(position:Position);
    Slash(position:Position);
    Colon(position:Position);
    Dot(position:Position);
    Comma(position:Position);
    DoubleQuote(position:Position);
    SingleQuote(position:Position);
}


/**
 *  Tokens iterator.
 */
class Tokenizer {

    inline static var cExclamationMark = 0x21;
    inline static var cQuestionMark = 0x3F;

    inline static var cOpenTag = 0x3C;
    inline static var cCloseTag = 0x3E;
    inline static var cSlash = 0x2F;
    inline static var cColon = 0x3A;

    inline static var cSquareBracketLeft = 0x5B;
    inline static var cSquareBracketRight = 0x5D;

    inline static var cDot = 0x2E;
    inline static var cMinus = 0x2D;
    inline static var cComma = 0x2C;
    inline static var cSpace = 0x20;
    inline static var cTab = 0x09;

    inline static var cDoubleQuote = 0x22;
    inline static var cSingleQuote = 0x27;

    var lastChr:Int;
    var lastCharPos:Int;
    var lastNonLiteral:Token;

    var source:Input;
    var position:Int;
    var fileName:String;
    var eofReached:Bool;

    public function new(source:Input, ?fileName:String) {

        this.source = source;
        this.fileName = fileName;
        this.position = 0;
        this.eofReached = false;

        updateLastChar();
    }

    private function updateLastChar() {
        try {
            lastChr = source.readByte();
            lastCharPos = position++;
            // Invalidate last nonliteral;
            lastNonLiteral = null;
        } catch (eof:haxe.io.Eof) {
            eofReached = true;
        }
    }

    function getLastCharIsNotLiteral():Token {

        if (lastNonLiteral != null) {
            return lastNonLiteral;
        }
        else {
            return lastNonLiteral = switch(lastChr) {
                case cOpenTag: OpenTag(nonLiteralPos());
                case cCloseTag: CloseTag(nonLiteralPos());
                case cExclamationMark: ExclamationMark(nonLiteralPos());
                case cQuestionMark: QuestionMark(nonLiteralPos());
                case cSquareBracketLeft: SquareBracketLeft(nonLiteralPos());
                case cSquareBracketRight: SquareBracketRight(nonLiteralPos());
                case cMinus: Minus(nonLiteralPos());
                case cSlash: Slash(nonLiteralPos());
                case cComma: Comma(nonLiteralPos());
                case cDot: Dot(nonLiteralPos());
                case cDoubleQuote: Token.DoubleQuote(nonLiteralPos());
                case cSingleQuote: Token.SingleQuote(nonLiteralPos());
                default: null;
            }
        }
    }

    function nonLiteralPos():Position {
        return { file:fileName, min:lastCharPos, max: position };
    }

    public function next():Token {

        var nonLiteral = getLastCharIsNotLiteral();

        if (nonLiteral != null) {
            updateLastChar();
            return nonLiteral;
        }
        else {

            var buf:BytesOutput = new BytesOutput();
            var startPos = lastCharPos;
            var whitespace:Bool = true;

            do {
                if (lastChr != cTab && lastChr != cSpace) {
                    whitespace = false;
                }
                buf.writeInt8(lastChr);
                updateLastChar();
                nonLiteral = getLastCharIsNotLiteral();
            }
            while (!eofReached && nonLiteral == null);

            if (!whitespace || eofReached) {
                return Literal(buf.getBytes().toString(), { file:fileName, min:startPos, max: lastCharPos });
            }
            else {
                return next();
            }
        }
    }

    public function hasNext():Bool {
        return !eofReached;
    }

    public function iterator():Iterator<Token> {
        return this;
    }
}

private class Parser {

    var tokens:Iterable<Token>;

    public function new(tokens:Iterable<Token>) {
        this.tokens = tokens;
    }

    public function parse():XML176Document {
        for (t in tokens) {

        }

        return null;
    }
}