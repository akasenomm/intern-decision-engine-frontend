import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inbank_frontend/fonts.dart';
import 'package:inbank_frontend/widgets/national_id_field.dart';

import '../api_service.dart';
import '../colors.dart';

class LoanForm extends StatefulWidget {
  const LoanForm({Key? key}) : super(key: key);

  @override
  _LoanFormState createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  String _nationalId = '';
  int _loanAmount = 2500;
  int _loanPeriod = 36;
  int _loanAmountResult = 0;
  int _loanPeriodResult = 0;
  String _errorMessage = '';
  String _selectedCountry = 'Select Country';

  List<DropdownMenuItem<String>> _getCountryDropdown() {
    List<String> countries = ['Select Country', 'Estonia', 'Latvia', 'Lithuania'];
    return countries.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value, style: TextStyle(color: Colors.black)),
      );
    }).toList();
  }

  void _submitForm() async {
    if (_selectedCountry == 'Select Country') {
      return;
    }
    if (_formKey.currentState!.validate()) {
      final result = await _apiService.requestLoanDecision(
          _nationalId, _loanAmount, _loanPeriod, _selectedCountry);
      setState(() {
        int tempAmount = int.parse(result['loanAmount'].toString());
        int tempPeriod = int.parse(result['loanPeriod'].toString());

        if (tempAmount <= _loanAmount || tempPeriod > _loanPeriod) {
          _loanAmountResult = int.parse(result['loanAmount'].toString());
          _loanPeriodResult = int.parse(result['loanPeriod'].toString());
        } else {
          _loanAmountResult = _loanAmount;
          _loanPeriodResult = _loanPeriod;
        }
        _errorMessage = result['errorMessage'].toString();
      });
    } else {
      _loanAmountResult = 0;
      _loanPeriodResult = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth / 3;
    const minWidth = 500.0;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: max(minWidth, formWidth),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  FormField<String>(
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NationalIdTextFormField(
                            onChanged: (value) {
                              setState(() {
                                _nationalId = value ?? '';
                                _submitForm();
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 60.0),
                  Text('Loan Amount: $_loanAmount €', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Slider.adaptive(
                    value: _loanAmount.toDouble(),
                    min: 2000,
                    max: 10000,
                    divisions: 80,
                    label: '$_loanAmount €',
                    activeColor: AppColors.secondaryColor,
                    onChanged: (double newValue) {
                      setState(() {
                        _loanAmount = ((newValue.floor() / 100).round() * 100);
                        _submitForm();
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('2000€', style: TextStyle(color: Colors.white))),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('10000€', style: TextStyle(color: Colors.white))),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Text('Loan Period: $_loanPeriod months', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Slider.adaptive(
                    value: _loanPeriod.toDouble(),
                    min: 12,
                    max: 60,
                    divisions: 40,
                    label: '$_loanPeriod months',
                    activeColor: AppColors.secondaryColor,
                    onChanged: (double newValue) {
                      setState(() {
                        _loanPeriod = ((newValue.floor() / 6).round() * 6);
                        _submitForm();
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('12 months', style: TextStyle(color: Colors.white))),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('60 months', style: TextStyle(color: Colors.white))),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(3.0),
                    child: DropdownButton<String>(
                      value: _selectedCountry,
                      items: _getCountryDropdown(),
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCountry = newValue!;
                          _submitForm();
                        });
                      },
                    ),
                  )
                  ,
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              Text(
                  'Approved Loan Amount: ${_loanAmountResult != 0 ? _loanAmountResult : "--"} €', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8.0),
              Text(
                  'Approved Loan Period: ${_loanPeriodResult != 0 ? _loanPeriodResult : "--"} months', style: TextStyle(color: Colors.white)),
              Visibility(
                  visible: _errorMessage != '',
                  child: Text(_errorMessage, style: errorMedium))
            ],
          ),
        ],
      ),
    );
  }
}
