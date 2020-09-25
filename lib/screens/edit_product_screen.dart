import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/product.dart';
import 'package:shop_app/provider/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit_product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlFocus = FocusNode();
  final _imageUrlController = TextEditingController();
  var _form = GlobalKey<FormState>();
  var _editProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );
  var _inInit = true;
  var _initValid = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': ''
  };
  var _isLoaded = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _priceFocus.dispose();
    _imageUrlController.dispose();
    _descriptionFocus.dispose();
    _imageUrlFocus.removeListener(_imageUpdating);
    _imageUrlFocus.dispose();
  }

  @override
  void initState() {
    _imageUrlFocus.addListener(_imageUpdating);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_inInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<ProductsProvider>(context).findById(productId);
        _initValid = {
          'title': _editProduct.title,
          'price': _editProduct.price.toString(),
          'description': _editProduct.description,
          'imageUrl': ''
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _inInit = false;
  }

  void _imageUpdating() {
    if (!_imageUrlFocus.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final validate = _form.currentState.validate();
    if (!validate) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoaded = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateItem(_editProduct.id, _editProduct);
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addItem(_editProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('That\'s error'),
                content: Text('something went wrong '),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Okay'))
                ],
              );
            });
      }
    }
    setState(() {
      _isLoaded = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editing item',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
            ),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoaded
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValid['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_priceFocus),
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: value,
                              description: _editProduct.description,
                              price: _editProduct.price,
                              imageUrl: _editProduct.imageUrl,
                              isFavorite: _editProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter a title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValid['price'],
                        decoration: InputDecoration(labelText: 'price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocus,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_descriptionFocus),
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: _editProduct.title,
                              description: _editProduct.description,
                              price: double.parse(value),
                              imageUrl: _editProduct.imageUrl,
                              isFavorite: _editProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'please enter the valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'please enter the greater than a zero';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValid['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        focusNode: _descriptionFocus,
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: _editProduct.title,
                              description: value,
                              price: _editProduct.price,
                              imageUrl: _editProduct.imageUrl,
                              isFavorite: _editProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter a description';
                          }
                          if (value.length < 10) {
                            return 'please enter the full desc';
                          }

                          return null;
                        },
                      ),
                      Row(
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
                                    'Enter a Url',
                                  )
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlController.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'ImageUrl'),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocus,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onEditingComplete: () {
                                setState(() {});
                              },
                              onSaved: (value) {
                                _editProduct = Product(
                                    id: _editProduct.id,
                                    title: _editProduct.title,
                                    description: _editProduct.description,
                                    price: _editProduct.price,
                                    imageUrl: value,
                                    isFavorite: _editProduct.isFavorite);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'please enter a image Url';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'please enter the  valid url';
                                }
                                if (!value.endsWith('.jpg') &&
                                    !value.startsWith('.jpeg') &&
                                    !value.startsWith('.png')) {
                                  return 'please enter the  valid Image';
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
