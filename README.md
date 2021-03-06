Dart XML
========

Dart XML is a lightweight library for parsing, traversing, querying and building XML documents.

This library is open source, stable and well tested. Development happens on [GitHub](http://github.com/renggli/dart-xml). Feel free to report issues or create a pull-request there. The most recent stable versions are available through [pub.dartlang.org](http://pub.dartlang.org/packages/xml). General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/dart+xml).

Continuous build results are available from [Jenkins](http://jenkins.lukas-renggli.ch/job/dart-xml). Up-to-date [documentation](http://jenkins.lukas-renggli.ch/job/dart-xml/javadoc) is created automatically with every new push.


Basic Usage
-----------

### Installation

Add the dependency to your package's pubspec.yaml file:

    dependencies:
      xml: ">=2.0.0 <3.0.0"

Then on the command line run:

    $ pub get

To import the package into your Dart code write:

    import 'package:xml/xml.dart';

### Reading and Writing

To read XML input use the top-level function `parse(String input)`:

    var bookshelfXml = '''<?xml version="1.0"?>
        <bookshelf>
          <book>
            <title lang="english">Growing a Language</title>
            <price>29.99</price>
          </book>
          <book>
            <title lang="english">Learning XML</title>
            <price>39.95</price>
          </book>
          <price>132.00</price>
        </bookshelf>''';
    var document = parse(bookshelfXml);

The resulting object is an instance of `XmlDocument`. In case the document cannot be parsed, a `ParseError` is thrown.

To write back the parsed XML document simply call `toString()`:

    print(document.toString());

### Traversing and Querying

Accessors allow to access nodes in the XML tree:

- `attributes` returns an iterable over the attributes of the current node.
- `children` returns an iterable over the children of the current node.

There are various methods to traverse the XML tree along its axes:

- `preceding` returns an iterable over nodes preceding the opening tag of the current node in document order.
- `descendants` returns an iterable over the descendants of the current node in document order. This includes the attributes of the current node, its children, the grandchildren, and so on.
- `following` the nodes following the closing tag of the current node in document order.
- `ancestors` returns an iterable over the ancestor nodes of the current node, that is the parent, the grandparent, and so on. Note that this is the only iterable that traverses nodes in reverse document order.

For example, the `descendants` iterator could be used to extract all textual contents from an XML tree:

    var textual = document.descendants
        .where((node) => node is XmlText && !node.text.trim().isEmpty)
        .join('\n');
    print(textual);

Additionally, there are helpers to find elements with a specific tag:

- `findElements(String name)` finds direct children of the current node with the provided tag `name`.
- `findAllElements(String name)` finds direct and indirect children of the current node with the provided tag `name`.

For example, to find all the nodes with the _<title>_ tag you could write:

    var titles = document.findAllElements('title');

The above code returns a lazy iterator that recursively walks the XML document and yields all the element nodes with the requested tag name. To extract the textual contents call `text`:

    titles
        .map((node) => node.text)
        .forEach(print);

This prints _Growing a Language_ and _Learning XML_.

Similarly, to compute the total price of all the books one could write the following expression:

    var total = document.findAllElements('book')
        .map((node) => double.parse(node.findElements('price').single.text))
        .reduce((a, b) => a + b);
    print(total);

Note that this first finds all the books, and then extracts the price to avoid counting the price tag that is included in the bookshelf.

### Building

To build a new XML document use an `XmlBuilder`. The builder implements a small set of methods to build complete XML trees. To create the above bookshelf example one would write:

    var builder = new XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('bookshelf', nest: () {
      builder.element('book', nest: () {
        builder.element('title', nest: () {
          builder.attribute('lang', 'english');
          builder.text('Growing a Language');
        });
        builder.element('price', nest: 29.99);
      });
      builder.element('book', nest: () {
        builder.element('title', nest: () {
          builder.attribute('lang', 'english');
          builder.text('Learning XML');
        });
        builder.element('price', nest: 39.95);
      });
      builder.element('price', nest: 132.00);
    });
    var xml = builder.build();

Note the `element` method. It is quite sophisticated and supports many different optional named arguments:

- The most common is the `nest:` argument which is used to insert contents into the element. In most cases this will be a function that calls more methods on the builder to define attributes, declare namespaces and add child elements. However, the argument can also be a string or an arbitrary Dart object that is converted to a string and added as a text node.
- While attributes can be defined from within the element, for simplicity there is also an argument `attributes:` that takes a map to define simple name-value pairs.
- Furthermore we can provide an URI as the namespace of the element using `namespace:` and declare new namespace prefixes using `namespaces:`. For details see the documentation of the method.

The builder pattern allows you to easily extract repeated parts into specific methods. In the example above, one could put the part that writes a book into a separate method as follows:

    buildBook(XmlBuilder builder, String title, String language, num price) {
      builder.element('book', nest: () {
        builder.element('title', nest: () {
          builder.attribute('lang', 'english');
          builder.text(title);
        });
        builder.element('price', nest: price);
      });
    }

Misc
----

### Supports

- Standard well-formed XML and HTML.
- Decodes and encodes commonly used character entities.
- Querying and traversing API using Dart iterators.
- Building XML trees using a builder API.

### Limitations

- Doesn't validate namespace declarations.
- Doesn't validate schema declarations.
- Doesn't parse and enforce DTD.

### History

This library started as an example of the [PetitParser](https://github.com/renggli/PetitParserDart) library. To my own surprise various people started to use it to read XML files. In April 2014 I was asked to replace the original [dart-xml](https://github.com/prujohn/dart-xml) library from John Evans.

### License

The MIT License, see [LICENSE](https://github.com/renggli/dart-xml/raw/master/LICENSE).
