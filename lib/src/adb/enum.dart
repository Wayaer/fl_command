enum InputKeyEvent {
  /// home
  home('3'),
  back('4'),
  menu('82'),
  volumeUp('24'),
  volumeDown('25'),
  volumeMute('164'),
  power('26'),
  switchApp('187'),
  dpadUp('19'),
  dpadDown('20'),
  dpadLeft('21'),
  dpadRight('22'),
  dpadCenter('23'),
  ;

  const InputKeyEvent(this.id);

  final String id;
}
