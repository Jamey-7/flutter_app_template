import 'package:flutter_test/flutter_test.dart';
import 'package:app_template/shared/forms/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('returns error for null value', () {
        expect(Validators.required(null), equals('This field is required'));
      });

      test('returns error for empty string', () {
        expect(Validators.required(''), equals('This field is required'));
      });

      test('returns error for whitespace-only string', () {
        expect(Validators.required('   '), equals('This field is required'));
      });

      test('returns null for valid value', () {
        expect(Validators.required('test'), isNull);
      });

      test('uses custom field name', () {
        expect(
          Validators.required(null, fieldName: 'Name'),
          equals('Name is required'),
        );
      });
    });

    group('email', () {
      test('returns error for null value', () {
        expect(Validators.email(null), equals('Email is required'));
      });

      test('returns error for empty string', () {
        expect(Validators.email(''), equals('Email is required'));
      });

      test('returns error for invalid email format', () {
        expect(
          Validators.email('notanemail'),
          equals('Please enter a valid email address'),
        );
        expect(
          Validators.email('test@'),
          equals('Please enter a valid email address'),
        );
        expect(
          Validators.email('@example.com'),
          equals('Please enter a valid email address'),
        );
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name+tag@example.co.uk'), isNull);
      });
    });

    group('password', () {
      test('returns error for null value', () {
        expect(Validators.password(null), equals('Password is required'));
      });

      test('returns error for empty string', () {
        expect(Validators.password(''), equals('Password is required'));
      });

      test('returns error for short password', () {
        expect(
          Validators.password('short'),
          equals('Password must be at least 8 characters'),
        );
      });

      test('respects custom minLength', () {
        expect(
          Validators.password('123', minLength: 6),
          equals('Password must be at least 6 characters'),
        );
        expect(Validators.password('123456', minLength: 6), isNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('password123'), isNull);
      });
    });

    group('phone', () {
      test('returns error for null value', () {
        expect(
          Validators.phone(null),
          equals('Phone number is required'),
        );
      });

      test('returns error for empty string', () {
        expect(
          Validators.phone(''),
          equals('Phone number is required'),
        );
      });

      test('returns error for invalid phone number', () {
        expect(
          Validators.phone('123'),
          equals('Please enter a valid phone number'),
        );
        expect(
          Validators.phone('abc'),
          equals('Please enter a valid phone number'),
        );
      });

      test('returns null for valid phone number', () {
        expect(Validators.phone('1234567890'), isNull);
        expect(Validators.phone('+1 (555) 123-4567'), isNull);
        expect(Validators.phone('555-123-4567'), isNull);
      });
    });

    group('minLength', () {
      test('returns error for null value', () {
        expect(
          Validators.minLength(null, 5),
          equals('This field is required'),
        );
      });

      test('returns error for short value', () {
        expect(
          Validators.minLength('ab', 5),
          equals('This field must be at least 5 characters'),
        );
      });

      test('returns null for valid length', () {
        expect(Validators.minLength('12345', 5), isNull);
        expect(Validators.minLength('123456', 5), isNull);
      });

      test('uses custom field name', () {
        expect(
          Validators.minLength('ab', 5, fieldName: 'Username'),
          equals('Username must be at least 5 characters'),
        );
      });
    });

    group('maxLength', () {
      test('returns null for null value', () {
        expect(Validators.maxLength(null, 5), isNull);
      });

      test('returns error for long value', () {
        expect(
          Validators.maxLength('123456', 5),
          equals('This field must be no more than 5 characters'),
        );
      });

      test('returns null for valid length', () {
        expect(Validators.maxLength('12345', 5), isNull);
        expect(Validators.maxLength('1234', 5), isNull);
      });

      test('uses custom field name', () {
        expect(
          Validators.maxLength('123456', 5, fieldName: 'Code'),
          equals('Code must be no more than 5 characters'),
        );
      });
    });

    group('match', () {
      test('returns error for non-matching values', () {
        expect(
          Validators.match('password', 'different'),
          equals('Values do not match'),
        );
      });

      test('returns null for matching values', () {
        expect(Validators.match('password', 'password'), isNull);
      });

      test('uses custom field name', () {
        expect(
          Validators.match('password', 'different', fieldName: 'Passwords'),
          equals('Passwords do not match'),
        );
      });
    });

    group('url', () {
      test('returns error for null value', () {
        expect(Validators.url(null), equals('URL is required'));
      });

      test('returns error for invalid URL', () {
        expect(
          Validators.url('notaurl'),
          equals('Please enter a valid URL'),
        );
        expect(
          Validators.url('http://'),
          equals('Please enter a valid URL'),
        );
      });

      test('returns null for valid URL', () {
        expect(Validators.url('https://example.com'), isNull);
        expect(Validators.url('http://www.example.com/path?query=1'), isNull);
      });
    });

    group('numeric', () {
      test('returns error for null value', () {
        expect(
          Validators.numeric(null),
          equals('This field is required'),
        );
      });

      test('returns error for non-numeric value', () {
        expect(
          Validators.numeric('abc'),
          equals('This field must be a number'),
        );
      });

      test('returns null for valid numbers', () {
        expect(Validators.numeric('123'), isNull);
        expect(Validators.numeric('123.45'), isNull);
        expect(Validators.numeric('-123'), isNull);
      });

      test('uses custom field name', () {
        expect(
          Validators.numeric('abc', fieldName: 'Age'),
          equals('Age must be a number'),
        );
      });
    });

    group('combine', () {
      test('returns first error from validators', () {
        final combined = Validators.combine([
          Validators.required,
          (value) => Validators.minLength(value, 5),
        ]);

        expect(combined(null), equals('This field is required'));
        expect(
          combined('ab'),
          equals('This field must be at least 5 characters'),
        );
      });

      test('returns null when all validators pass', () {
        final combined = Validators.combine([
          Validators.required,
          (value) => Validators.minLength(value, 5),
          (value) => Validators.maxLength(value, 10),
        ]);

        expect(combined('12345'), isNull);
      });
    });
  });
}
