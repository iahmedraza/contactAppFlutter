import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:contactapp/client/hive_names.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../model/contact.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ContactsAdapter());
  await Hive.openBox<Contacts>(HiveBoxes.contact);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conatct',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Contact App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  void _showForm([dynamic index]) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              // overflow: Overflow.visible,
              children: <Widget>[
                // Positioned(
                //   right: -40.0,
                //   top: -40.0,
                //   child: InkResponse(
                //     onTap: () {
                //       Navigator.of(context).pop();
                //     },
                //     child: CircleAvatar(
                //       child: Icon(Icons.close),
                //       backgroundColor: Colors.red,
                //     ),
                //   ),
                // ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child:
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty ) {
                            return 'Enter name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          // icon: Icon(Icons.account_circle),
                          labelText: 'Name',
                        ),
                        controller: _name,
                      ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your phone no';
                        } else if (value.length != 11){
                          return 'Mobile Number must be of 11 digit';
                          }
                        else{
                          return null;
                          }
                    } ,
                        decoration: const InputDecoration(
                          // icon: Icon(Icons.account_circle),
                          labelText: 'Phone',
                        ),
                        controller: _contact,
                      ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: const Text("Submit"),
                          onPressed: () {

                      if (_formKey.currentState!.validate()) { 
                            
                            _onFormSubmit(index);
                            
                      }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }).then((exit) {
  if (exit == null) {
    _name.text = '';
    _contact.text = '';
    return;
    }
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Contacts>(HiveBoxes.contact).listenable(),
        builder: (context, Box<Contacts> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text("Contact list is empty"),
            );
          }
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              Contacts? res = box.getAt(index);
              return Slidable(
  // Specify a key if the Slidable is dismissible.
  key: const ValueKey(0),

  // The start action pane is the one at the left or the top side.
  startActionPane: ActionPane(
    // A motion is a widget used to control how the pane animates.
    motion: const ScrollMotion(),

    // All actions are defined in the children parameter.
    children:  [
      // A SlidableAction can have an icon and/or a label.
      SlidableAction(
        onPressed: (BuildContext) => res?.delete() ,
        backgroundColor: Color(0xFFFE4A49),
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),
    ],
  ),

  // The end action pane is the one at the right or the bottom side.
  endActionPane: ActionPane(
    motion: ScrollMotion(),
    children: [
      
      SlidableAction(
        onPressed: (BuildContext)  {
          _name.text = res?.name as String;
          _contact.text = res?.contact as String;
          _showForm(index);
        } ,
        backgroundColor: Color(0xFF0392CF),
        foregroundColor: Colors.white,
        icon: Icons.edit,
        label: 'Edit',
      ),
    ],
  ),

  // The child of the Slidable is what the user sees when the
  // component is not dragged.
   child: ListTile(
                  onTap: () async {
                    print(res);
                    await launcher.launch(
                    'tel://${res?.contact}',
                    useSafariVC: false,
                    useWebView: false,
                    enableJavaScript: false,
                    enableDomStorage: false,
                    universalLinksOnly: true,
                    headers: <String, String>{},);
                    Iterable<CallLogEntry> entries = await CallLog.query(
      number: res?.contact as String,
      type: CallType.outgoing,
    );
    print(entries);
                    },
                  title: Text(res?.name == null ? '' : res?.name as String),
                  subtitle:
                      Text(res?.contact == null ? '' : res?.contact as String),
                ),
);
              // return Dismissible(
              //   background: Container(color: Colors.red),
              //   key: UniqueKey(),
              //   onDismissed: (direction) {
              //     res?.delete();
              //   },
                // child: ListTile(
                //   onTap: () async {
                //     await launcher.launch(
                //     'tel://${res?.contact}',
                //     useSafariVC: false,
                //     useWebView: false,
                //     enableJavaScript: false,
                //     enableDomStorage: false,
                //     universalLinksOnly: true,
                //     headers: <String, String>{},);
                //     },
                //   title: Text(res?.name == null ? '' : res?.name as String),
                //   subtitle:
                //       Text(res?.contact == null ? '' : res?.contact as String),
                // ),
              // );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showForm,
        tooltip: 'Add Contact',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onFormSubmit([dynamic index]) {
    Box<Contacts> contactsBox = Hive.box<Contacts>(HiveBoxes.contact);
    Contacts value = Contacts(name: _name.text, contact: _contact.text);
    if (index == null){
    contactsBox.add(value);
    } else {
      contactsBox.putAt(index, value);
    }
    _name.text = '';
    _contact.text = '';
    Navigator.of(context).pop();
  }
}
