package com.tenderowls.xml176;

import com.tenderowls.xml176.XML176Document;
import com.tenderowls.xml176.Tokenizer;
import haxe.macro.Expr.Position;

using Tokenizer.Tokens;

class Parser {

    var t:Token;
    var tokens:Iterable<Token>;
    var namespaces:Map<String, Namespace>;

    public function new(tokens:Iterable<Token>) {
        this.tokens = tokens;
    }

    public function parse():XML176Document {
        return parseNode(tokens.iterator(), true);
    }

    function resolveNamespace(s:String):Namespace {

        var ns = namespaces.get(s);

        if (ns == null) {
            ns = new Namespace(s);
            namespaces.set(s, ns);
        }

        return ns;
    }

    function parseNode(iter:Iterator<Token>, isRootNode:Bool):XML176Document {

        if (!iter.hasNext())
            return null;

        var namespace:Namespace = null;
        var tagName:String = null;
        var children = new Array<XML176Document>();

        t = iter.next();
        var firstToken = t;

        switch (t) {
            case Token.OpenTag(p):
                t = iter.next();
                switch (t) {
                    case Token.Literal(tagNameOrNamespace, _):
                        t = iter.next();
                        switch (t) {
                            case Token.Colon(p):
                                namespace = resolveNamespace(tagNameOrNamespace);
                                t = iter.next();
                                switch (t) {
                                    case Token.Literal(value, _):
                                        tagName = value;
                                        parseNodeChildren(children, iter);
                                        parseNodeFinalizer(namespace, tagName, iter);
                                    default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
                                }
                            default:
                                tagName = tagNameOrNamespace;
                                parseNodeChildren(children, iter);
                                parseNodeFinalizer(namespace, tagName, iter);
                        }
                    case Token.Slash(p):
                        throw new UnexpectedTagFinalizer(t.tokenPosition());
                    case Token.ExclamationMark(_):
                    // TODO parseComment
                    // TODO parseCDATA
                    default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
                }
            case Token.Whitespace(_,_):
                return parseNode(iter, isRootNode);
            default: throw new UnexpectedError("<", t.tokenToName(), t.tokenPosition());
        }

        var firstTokenPos = firstToken.tokenPosition();
        var tPos = t.tokenPosition();

        return XML176Document.Node(
            new QName(namespace, tagName),
            children,
            { file: firstTokenPos.file, min: firstTokenPos.min, max: tPos.max }
        );
    }

    function parseNodeChildren(children:Array<XML176Document>, iter:Iterator<Token>) {
        var attrStream = new List<Token>();
        // Fill attribute tokens list
        if (!t.isCloseTag()) {
            while (!(t = iter.next()).isCloseTag()) {
                attrStream.add(t);
            }
            // Parse attr tokens
            var attr:XML176Document, attrStreamIter = attrStream.iterator();
            while ((attr = parseAttr(attrStreamIter)) != null) {
                children.push(attr);
            }
        }
        // Parse children
        try {
            var childNode;
            while ((childNode = parseNode(iter, false)) != null) {
                children.push(childNode);
            }
        }
        catch (e:UnexpectedTagFinalizer) {
            t = iter.next();
            switch (t) {
                case Literal(value, p):
                default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
            }
        }
    }

    function parseAttr(iter:Iterator<Token>):XML176Document {

        if (!iter.hasNext())
            return null;

        var attrName:String = null;
        var ns:Namespace = null;
        var value:String = null;

        t = iter.next();
        var firstToken = t;

        switch (t) {
            case Token.Whitespace(_,_): return parseAttr(iter);
            case Token.Literal(attrNameOrNamespace, _):
                t = iter.next();
                switch (t) {
                    case Token.Colon(_):
                        ns = resolveNamespace(attrNameOrNamespace);
                        t = iter.next();
                        switch (t) {
                            case Token.Literal(v,_):
                                attrName = v;
                                value = parseAttrValue(iter);
                            default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
                        }
                    default:
                        attrName = attrNameOrNamespace;
                        value = parseAttrValue(iter, t);
                }
            default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
        }

        var firstTokenPos = firstToken.tokenPosition();
        var tPos = t.tokenPosition();

        return XML176Document.Attr(
            new QName(ns, attrName),
            value,
            { file: firstTokenPos.file, min: firstTokenPos.min, max: tPos.max }
        );
    }

    function parseAttrValue(iter:Iterator<Token>, ?startWith:Token):String {
        t = startWith != null ? startWith : iter.next();
        switch (t) {
            case Token.Equals(_):
                t = iter.next();
                switch (t) {
                    case Token.DoubleQuote(_):
                        var valueTokens = new List<Token>();
                        while (!(t = iter.next()).isDoubleQuote()) {
                            valueTokens.add(t);
                        }
                        return valueTokens.tokensToString();
                    default: throw new UnexpectedError("\" or '", t.tokenToName(), t.tokenPosition());
                }
            default: throw new UnexpectedError("=", t.tokenToName(), t.tokenPosition());
        }
    }

    function parseNodeFinalizer(ns:Namespace, name:String, iter:Iterator<Token>) {

    }
}

private class UnexpectedTagFinalizer extends ParserError {

    public function new(p:Position) {
        super("Unexpected node finalizer", p);
    }
}

class UnexpectedError extends ParserError {

    public function new(expected:String, given:String, p:Position) {
        super("`" + expected + "` expected, but `" + given + "` given", p);
    }
}

class ParserError {

    public var message:String;
    public var position:Position;

    public function new(message:String, position:Position) {
        this.message = message;
        this.position = position;
    }

    public function toString() {
        return message + " at " + position;
    }
}