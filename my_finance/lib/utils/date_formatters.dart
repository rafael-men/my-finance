const List<String> kMonths = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
];

const List<String> kShortMonths = [
  'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
];


const List<String> kWeekdayNames = [
  'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
];

const List<String> kShortWeekdayNames = [
  'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
];

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String fullMonthName(int month) => kMonths[month - 1];

String shortMonthName(int month) => kShortMonths[month - 1];

String weekdayName(DateTime date) => kWeekdayNames[date.weekday - 1];

String shortWeekdayName(DateTime date) => kShortWeekdayNames[date.weekday - 1];
