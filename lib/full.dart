part of ice;

class Full {
  Element el;
  Editor ice;
  Store store;

  Full({enable_javascript_mode: true}) {
    el = new Element.html('<div id=ice>');
    document.body.nodes.add(el);

    ice = new Editor('#ice', enable_javascript_mode: enable_javascript_mode);
    store = new Store();

    _attachToolbar();
    _attachKeyboardHandlers();
    _attachMouseHandlers();

    _fullScreenStyles();

    editorReady.then((_)=> _applyStyles());
    editorReady.then((_)=> content = store.isEmpty ?
      '' : store.projects.first['code']);
  }

  Future get editorReady => ice.editorReady;
  String get content => ice.content;
  void set content(data) => ice.content = data;

  _attachToolbar() {
    var toolbar = new Element.html('<div class=ice-toolbar>');
    toolbar.style
      ..position = 'absolute'
      ..top = '10px'
      ..right = '20px'
      ..zIndex = '999';

    _attachMainMenuButton(toolbar);

    el.children.add(toolbar);
  }

  _attachMainMenuButton(parent) {
    var el = new Element.html('<button>☰</button>');
    parent.children.add(el);

    el.onClick.listen((e)=> this.toggleMainMenu());
  }

  _attachKeyboardHandlers() {
    document.onKeyUp.listen((e) {
      if (!_isEscapeKey(e)) return;
      _hideMenu();
      _hideDialog();
    });
  }

  _attachMouseHandlers() {
    editorReady.then((_){
      el.query('.ice-code-editor-editor').
        onClick.
        listen((e){
          _hideMenu();
          _hideDialog();
        });
    });
  }

  _isEscapeKey(e) =>
    e.keyCode == 27 || e.$dom_keyIdentifier.codeUnits.first == 27;

  toggleMainMenu() {
    if (queryAll('.ice-menu,.ice-dialog').isEmpty) _showMainMenu();
    else {_hideMenu(); _hideDialog();}
  }

  _showMainMenu() {
    var menu = new Element.html('<ul class=ice-menu>');
    el.children.add(menu);

    menu.children
      ..add(_openDialog)
      ..add(_newProjectDialog)
      ..add(_copyDialog)
      ..add(_saveMenu)
      ..add(_renameDialog)
      ..add(_shareDialog)
      ..add(_downloadDialog)
      ..add(_removeDialog)
      ..add(_helpDialog);
  }

  get _openDialog=>       new MenuItem(new OpenDialog(this)).el;
  get _newProjectDialog=> new MenuItem(new NewProjectDialog(this)).el;
  get _renameDialog=>     new MenuItem(new RenameDialog(this)).el;
  get _copyDialog=>       new MenuItem(new CopyDialog(this)).el;
  get _saveMenu=>         new MenuItem(new SaveMenu(this)).el;
  get _shareDialog=>      new MenuItem(new ShareDialog(this)).el;
  get _removeDialog=>     new MenuItem(new RemoveDialog(this)).el;
  get _downloadDialog=> new DownloadDialog(this).el;
  get _helpDialog=>     new HelpDialog(this).el;

  String get encodedContent => Gzip.encode(ice.content);

  _fullScreenStyles() {
    document.body.style
      ..margin = '0px'
      ..overflow = 'hidden';
  }

  _applyStyles() {
     var editor_el = el.query('.ice-code-editor-editor');

     editor_el.style
       ..top = '0'
       ..bottom = '0'
       ..left = '0'
       ..right = '0'
       ..backgroundColor = 'rgba(255,255,255,0.0)';

     el.style
       ..height = '100%'
       ..width = '100%';
  }
}

_hideMenu() {
  queryAll('.ice-menu').forEach((e)=> e.remove());
}

_hideDialog() {
  queryAll('.ice-dialog').forEach((e)=> e.remove());
}

class DownloadDialog {
  DownloadDialog(Full full);
  Element get el {
    return new Element.html('<li>Download</li>');
  }
}
class HelpDialog {
  HelpDialog(Full full);
  Element get el {
    return new Element.html('<li>Help</li>');
  }
}

_isEscapeKey(e) =>
  e.keyCode == 27 || e.$dom_keyIdentifier.codeUnits.first == 27;

_isEnterKey(e) =>
  e.keyCode == 13 || e.$dom_keyIdentifier.codeUnits.first == 13;
