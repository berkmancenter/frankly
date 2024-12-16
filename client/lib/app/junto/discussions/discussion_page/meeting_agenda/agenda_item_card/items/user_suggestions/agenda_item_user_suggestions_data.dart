class AgendaItemUserSuggestionsData {
  String headline;

  AgendaItemUserSuggestionsData(this.headline);

  AgendaItemUserSuggestionsData.newItem() : headline = '';

  bool isNew() {
    return headline.isEmpty;
  }
}
