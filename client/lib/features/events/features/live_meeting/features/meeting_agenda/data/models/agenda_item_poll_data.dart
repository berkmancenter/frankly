class AgendaItemPollData {
  String question;
  List<String> answers;

  AgendaItemPollData(this.question, this.answers);

  AgendaItemPollData.newItem()
      : question = '',
        answers = [];

  bool isNew() {
    return question.isEmpty && answers.isEmpty;
  }
}
