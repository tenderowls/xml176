package com.tenderowls.xml176;

import com.tenderowls.xml176.XML176Document;
import com.tenderowls.xml176.Tokenizer;
import haxe.macro.Expr.Position;

using Tokenizer.Tokens;

private class Parser {

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

        var namespace:Namespace = null;
        var tagName:String = null;
        var children = new List<XML176Document>();

        t = iter.next();
        var firstToken = t;

        switch (t) {
            case Token.OpenTag(p):
                t = iter.next();
                switch (t) {
                    case Token.Literal(nameOrNameSpace, _):
                        t = iter.next();
                        switch (t) {
                            case Token.Colon(p):
                                namespace = resolveNamespace(nameOrNameSpace);
                                t = iter.next();
                                switch (t) {
                                    case Token.Literal(value, _):
                                        tagName = value;
                                        var attrStream = new List<Token>();
                                        // Fill attribute tokens list
                                        while (!(t = iter.next()).isCloseTag()) {
                                            attrStream.add(t);
                                        }
                                        // Parse attr tokens
                                        var attr:XML176Document, attrStreamIter = attrStream.iterator();
                                        while ((attr = parseAttr(attrStreamIter)) != null) {
                                            children.add(attr);
                                        }
                                        // Parse children
                                        try {
                                            while (true) {
                                                children.add(parseNode(iter, false));
                                            }
                                        }
                                        catch (e:UnexpectedTagFinalizer) {
                                            t = iter.next();
                                            switch (t) {
                                                case Literal(value, p):
                                                default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
                                            }
                                        }
                                    default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
                                }
                            case Token.CloseTag(_):
                                tagName = nameOrNameSpace;
                                // Parse children
                                try {
                                    while (true) {
                                        children.add(parseNode(iter, false));
                                    }
                                }
                                catch (e:UnexpectedTagFinalizer) {
                                    t = iter.next();
                                    switch (t) {
                                        case Literal(value, p):
                                        default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
                                    }
                                }
                            default:
                            // TODO error
                        }
                    case Token.Slash(p):
                        throw new UnexpectedTagFinalizer(t.tokenPosition());
                    case Token.ExclamationMark(_):
                    // TODO parseComment
                    // TODO parseCDATA
                    default: throw new UnexpectedError("name", t.tokenToName(), t.tokenPosition());
                }
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

    function parseAttr(iter:Iterator<Token>):XML176Document {
        return null;
    }
}

private class UnexpectedTagFinalizer extends ParserError {

    public function new(p:Position) {
        super("Unexpected node finalizer", p);
    }
}

class UnexpectedError extends ParserError {

    public function new(expected:String, given:String, p:Position) {
        super(expected + " expected, but " + given + " given", p);
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