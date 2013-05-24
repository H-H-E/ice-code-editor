part of ice;

class Full {
  Element el;
  Editor _ice;
  Store _store;

  Full({enable_javascript_mode: true}) {
    el = new Element.html('<div id=ice>');
    document.body.nodes.add(el);

    _attachToolbar();
    _fullScreenStyles();
    _ice = new Editor('#ice', enable_javascript_mode: enable_javascript_mode);
    _store = new Store();

    editorReady.then((_)=> _applyStyles());
    editorReady.then((_)=> content = _store.isEmpty ?
      '' : _store.projects.first['code']);
  }

  Future get editorReady => _ice.editorReady;
  String get content => _ice.content;
  void set content(data) => _ice.content = data;

  _attachToolbar() {
    var toolbar = new Element.html('<div class=ice-toolbar>');
    toolbar.style
      ..position = 'absolute'
      ..top = '10px'
      ..right = '20px'
      ..zIndex = '999';

    _attachMainMenuButton(toolbar);
    _attachKeyboardHandlers();

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

  _isEscapeKey(e) =>
    e.keyCode == 27 || e.$dom_keyIdentifier.codeUnits.first == 27;

  toggleMainMenu() {
    if (queryAll('.ice-menu').isEmpty) _showMainMenu();
    else _hideMenu();
  }

  _showMainMenu() {
    var menu = new Element.html('<ul class=ice-menu>');
    el.children.add(menu);

    menu.children
      ..add(_projectsMenuItem())
      ..add(_newProjectMenuItem)
      ..add(new Element.html('<li>Rename</li>'))
      ..add(new Element.html('<li>Make a Copy</li>'))
      ..add(_saveMenuItem)
      ..add(_shareMenuItem())
      ..add(new Element.html('<li>Download</li>'))
      ..add(new Element.html('<li>Help</li>'));
  }

  _hideMenu() {
    queryAll('.ice-menu').forEach((e)=> e.remove());
  }

  _hideDialog() {
    queryAll('.ice-dialog').forEach((e)=> e.remove());
  }

  get _newProjectMenuItem {
    return new Element.html('<li>New</li>')
      ..onClick.listen((e)=> _openNewProjectDialog());
  }

  _openNewProjectDialog() {
    _hideMenu();

    var dialog = new Element.html(
        '''
        <div class=ice-dialog>
        <label>Name:<input type="text" size="30"></label>
        <button>Save</button>
        </div>
        '''
    );

    dialog.query('button').onClick.listen((e)=> _saveNewProject());

    el.children.add(dialog);
  }

  _saveNewProject() {
    var title = query('.ice-dialog').query('input').value;
    _store[title] = {};

    query('.ice-dialog').remove();
  }

  _projectsMenuItem() {
    return new Element.html('<li>Projects</li>')
      ..onClick.listen((e)=> _hideMenu())
      ..onClick.listen((e)=> _openProjectsMenu());
  }

  _openProjectsMenu() {
    var menu = new Element.html(
      '''
      <div class=ice-menu>
      <h1>Saved Projects</h1>
      <ul></ul>
      </div>
      '''
    );

    _store.forEach((title, data) {
      var project = new Element.html('<li>${title}</li>')
        ..onClick.listen((e)=> _openProject(title))
        ..onClick.listen((e)=> _hideMenu());

      menu.query('ul').children.add(project);
    });

    el.children.add(menu);

    menu.style
      ..maxHeight = '560px'
      ..overflowY = 'auto'
      ..position = 'absolute'
      ..right = '25px'
      ..top = '60px'
      ..zIndex = '1000';
  }

  _openProject(title) {
    // TODO: Move this into Store (should be a way to make a project as
    // current)
    var project = _store.remove(title);
    _store[title] = project;
    _ice.content = project['code'];
  }

  Element get _saveMenuItem {
    return new Element.html('<li>Save</li>')
      ..onClick.listen((e)=> _save())
      ..onClick.listen((e)=> _hideMenu());
  }

  void _save() {
    var title = _store.isEmpty ? 'Untitled' : _store.projects.first['title'];

    _store[title] = {'code': content};
  }

  _shareMenuItem() {
    return new Element.html('<li>Share</li>')
      ..onClick.listen((e) => _openShareDialog());
  }

  _openShareDialog() {
    var dialog = new Element.html(
        '''
        <div class=ice-dialog>
        <h1>Copy this link to share your creation:</h1>
        <input
          value="http://gamingjs.com/ice/#B/${encodedContent}"
          style="width=400px; padding=5px; border=0px">
        </div>
        '''
    );

    el.children.add(dialog);

    dialog.style
      ..left = "${(window.innerWidth - dialog.offsetWidth)/2}px"
      ..top = "${(window.innerHeight - dialog.offsetHeight)/2}px";
  }

  String get encodedContent => Gzip.encode(_ice.content);

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
