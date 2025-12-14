from gi.repository import Nautilus, GObject, Gio
import subprocess

class BaobabExtension(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        pass

    def open_baobab(self, menu, file):
        uri = file.get_uri()
        gfile = Gio.File.new_for_uri(uri)
        path = gfile.get_path()
        if path:
            subprocess.Popen(["baobab", path])

    def get_file_items(self, files):
        if len(files) != 1:
            return

        file = files[0]
        if not file.is_directory() or file.get_uri_scheme() != 'file':
            return

        item = Nautilus.MenuItem(
            name='BaobabExtension::Analyze_Disk_Usage',
            label='Analyser l\'utilisation du disque',
            tip='Voir la répartition des fichiers avec Baobab'
        )
        item.connect('activate', self.open_baobab, file)
        return item,

    def get_background_items(self, file):
        if file.get_uri_scheme() != 'file':
             return

        item = Nautilus.MenuItem(
            name='BaobabExtension::Analyze_Current_Folder',
            label='Analyser l\'utilisation du disque ici',
            tip='Voir la répartition des fichiers du dossier courant'
        )
        item.connect('activate', self.open_baobab, file)
        return item,
