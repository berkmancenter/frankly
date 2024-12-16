class AgendaItemImageData {
  String title;
  String url;

  AgendaItemImageData(this.title, this.url);

  AgendaItemImageData.newItem()
      : title = '',
        url = '';

  bool isNew() {
    return title.isEmpty && url.isEmpty;
  }
}
