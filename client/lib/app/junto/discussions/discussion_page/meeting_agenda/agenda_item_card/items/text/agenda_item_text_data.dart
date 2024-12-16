class AgendaItemTextData {
  String title;
  String content;

  AgendaItemTextData(this.title, this.content);

  AgendaItemTextData.newItem()
      : title = '',
        content = '';

  bool isNew() {
    return title.isEmpty && content.isEmpty;
  }
}
