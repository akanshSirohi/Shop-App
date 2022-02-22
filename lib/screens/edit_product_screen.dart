import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: "",
    title: "",
    description: "",
    price: 0,
    imageUrl: "",
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = false;
  var _isEditing = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId != '0') {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
        _isEditing = true;
      }
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith("http")) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    if (_isEditing) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(onPressed: _saveForm, icon: Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(labelText: "Title"),
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please provide a value!";
                  }
                  return null;
                },
                onSaved: (val) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: val.toString(),
                    description: _editedProduct.description,
                    price: _editedProduct.price,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: "Price"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter a price!';
                  }
                  if (double.tryParse(val) == null) {
                    return 'Please enter a valid number!';
                  }
                  if (double.parse(val) <= 0) {
                    return 'Please enter a number greater than zero!';
                  }
                  return null;
                },
                onSaved: (val) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    description: _editedProduct.description,
                    price: double.parse(val.toString()),
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please enter a description!";
                  }
                  if (val.length < 10) {
                    return "Should be more than 10 characters!";
                  }
                  return null;
                },
                onSaved: (val) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    description: val.toString(),
                    price: _editedProduct.price,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text(
                            "No image to show...",
                            textAlign: TextAlign.center,
                          )
                        : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Image URL"),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) {
                        if (!_imageUrlController.text.startsWith("http")) {
                          return;
                        }
                        setState(() {});
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter an image URL";
                        }
                        if (!val.startsWith("http")) {
                          return "Please enter a valid URL";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: val.toString(),
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
