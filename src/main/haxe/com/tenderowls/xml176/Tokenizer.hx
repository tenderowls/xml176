package com.tenderowls.xml176;

import haxe.io.Input;
import haxe.macro.Expr.Position;
import haxe.io.BytesOutput;

enum Token {

    Literal(value:String, position:Position);
    Whitespace(size:Int, position:Position);

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

class Tokens {

    inline static public var cExclamationMark = 0x21;
    inline static public var cQuestionMark = 0x3F;

    inline static public var cOpenTag = 0x3C;
    inline static public var cCloseTag = 0x3E;
    inline static public var cSlash = 0x2F;
    inline static public var cColon = 0x3A;

    inline static public var cSquareBracketLeft = 0x5B;
    inline static public var cSquareBracketRight = 0x5D;

    inline static public var cDot = 0x2E;
    inline static public var cMinus = 0x2D;
    inline static public var cComma = 0x2C;

    inline static public var cDoubleQuote = 0x22;
    inline static public var cSingleQuote = 0x27;

    public inline static function isCloseTag(t:Token):Bool {
        return switch (t) {
            case Token.CloseTag: true;
            default: false;
        }
    }

    public static function tokenPosition(t:Token):Position {
        return switch(t) {
            case Literal(_, p): p;
            case ExclamationMark(p): p;
            case QuestionMark(p): p;
            case OpenTag(p): p;
            case CloseTag(p): p;
            case SquareBracketLeft(p): p;
            case SquareBracketRight(p): p;
            case Minus(p): p;
            case Slash(p): p;
            case Colon(p): p;
            case Dot(p): p;
            case Comma(p): p;
            case DoubleQuote(p): p;
            case SingleQuote(p): p;
            case Whitespace(_, p): p;
        }
    }

    public static function tokenToName(t:Token):String {

        return switch(t) {
            case Literal(_, _): "literal";
            case ExclamationMark(_): "!";
            case QuestionMark(_): "?";
            case OpenTag(_): "<";
            case CloseTag(_): ">";
            case SquareBracketLeft(_): "[";
            case SquareBracketRight(_): "]";
            case Minus(_): "-";
            case Slash(_): "/";
            case Colon(_): ":";
            case Dot(_): ".";
            case Comma(_): ",";
            case DoubleQuote(_): "\"";
            case SingleQuote(_): "\'";
            case Whitespace(_): "whitespace";
        }
    }
}

/**
 *  Tokens iterator.
 */
class Tokenizer {

    inline static var cSpace = 0x20;
    inline static var cTab = 0x09;

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

    inline function getLastCharIsWhiteSpace():Bool {
        return lastChr == cTab || lastChr == cSpace;
    }

    function getLastCharIsNotLiteral():Token {

        if (lastNonLiteral != null) {
            return lastNonLiteral;
        }
        else {
            return lastNonLiteral = switch(lastChr) {
                case Tokens.cOpenTag: OpenTag(nonLiteralPos());
                case Tokens.cCloseTag: CloseTag(nonLiteralPos());
                case Tokens.cExclamationMark: ExclamationMark(nonLiteralPos());
                case Tokens.cQuestionMark: QuestionMark(nonLiteralPos());
                case Tokens.cSquareBracketLeft: SquareBracketLeft(nonLiteralPos());
                case Tokens.cSquareBracketRight: SquareBracketRight(nonLiteralPos());
                case Tokens.cMinus: Minus(nonLiteralPos());
                case Tokens.cSlash: Slash(nonLiteralPos());
                case Tokens.cComma: Comma(nonLiteralPos());
                case Tokens.cDot: Dot(nonLiteralPos());
                case Tokens.cDoubleQuote: Token.DoubleQuote(nonLiteralPos());
                case Tokens.cSingleQuote: Token.SingleQuote(nonLiteralPos());
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

            var startPos = lastCharPos;

            if (getLastCharIsWhiteSpace()) {
                // Read whitespaces
                var whitespace:Int = 0;
                do {
                    whitespace++;
                    updateLastChar();
                } while (getLastCharIsWhiteSpace());
                return Token.Whitespace(
                    whitespace,
                    { file:fileName, min:startPos, max: lastCharPos }
                );
            }
            else {
                var buf:BytesOutput = new BytesOutput();
                do {
                    buf.writeInt8(lastChr);
                    updateLastChar();
                }
                while (!eofReached && getLastCharIsNotLiteral() == null && !getLastCharIsWhiteSpace());
                return Token.Literal(
                    buf.getBytes().toString(),
                    { file:fileName, min:startPos, max: lastCharPos }
                );
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
