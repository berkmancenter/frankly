class AgendaItemWordCloudData {
  String prompt;

  AgendaItemWordCloudData(this.prompt);

  AgendaItemWordCloudData.newItem() : prompt = '';

  bool isNew() {
    return prompt.isEmpty;
  }
}
