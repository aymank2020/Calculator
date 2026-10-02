import 'package:flutter_test/flutter_test.dart';
import 'package:number_base/logic.dart';

void main() {
  test('converts decimal to all four bases', () {
    expect(convertInteger('255', IntegerBase.decimal), {
      IntegerBase.binary: '11111111',
      IntegerBase.octal: '377',
      IntegerBase.decimal: '255',
      IntegerBase.hexadecimal: 'FF',
    });
  });

  test('preserves negative signs and supports explicit positive signs', () {
    expect(
      convertInteger(' -ff ', IntegerBase.hexadecimal)[IntegerBase.decimal],
      '-255',
    );
    expect(parseInteger('+101', IntegerBase.binary), BigInt.from(5));
    expect(parseInteger('-0', IntegerBase.octal), BigInt.zero);
  });

  test('converts every source radix', () {
    for (final entry in {
      IntegerBase.binary: '101010',
      IntegerBase.octal: '52',
      IntegerBase.decimal: '42',
      IntegerBase.hexadecimal: '2a',
    }.entries) {
      expect(parseInteger(entry.value, entry.key), BigInt.from(42));
    }
  });

  test('retains precision far beyond 64 bit integers', () {
    const decimal = '340282366920938463463374607431768211455';
    final output = convertInteger(decimal, IntegerBase.decimal);
    expect(output[IntegerBase.hexadecimal], 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
    expect(output[IntegerBase.binary], List.filled(128, '1').join());
    expect(
      convertInteger(
        output[IntegerBase.hexadecimal]!,
        IntegerBase.hexadecimal,
      )[IntegerBase.decimal],
      decimal,
    );
  });

  test('rejects digits invalid for their source base', () {
    for (final entry in {
      IntegerBase.binary: '102',
      IntegerBase.octal: '89',
      IntegerBase.decimal: '1A',
      IntegerBase.hexadecimal: 'FG',
    }.entries) {
      expect(() => parseInteger(entry.value, entry.key), throwsFormatException);
    }
  });

  test('rejects empty input, malformed signs, separators, and prefixes', () {
    for (final input in [
      '',
      '  ',
      '-',
      '+',
      '--1',
      '+-1',
      '1 2',
      '1.5',
      '0xFF',
      '1_0',
    ]) {
      expect(
        () => parseInteger(input, IntegerBase.hexadecimal),
        throwsFormatException,
        reason: input,
      );
    }
  });
}
