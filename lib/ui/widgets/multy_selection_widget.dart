import 'package:flutter/material.dart';

class CustomMultiSelectDropdownField<T> extends StatefulWidget {
  final String label;
  final String hintText;
  final List<T> selectedValues;
  final bool? isMandatory;
  final List<T> items;
  final ValueChanged<List<T>> onChanged;

  const CustomMultiSelectDropdownField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.selectedValues,
    this.isMandatory,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomMultiSelectDropdownFieldState<T> createState() =>
      _CustomMultiSelectDropdownFieldState<T>();
}

class _CustomMultiSelectDropdownFieldState<T>
    extends State<CustomMultiSelectDropdownField<T>> {
  bool isDropdownOpen = false; // Track if the dropdown is open or closed

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.label ==''? SizedBox.shrink():   Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(color: Colors.black),
            ),
            if (widget.isMandatory == true)
              Text(
                "*",
                style: TextStyle(
                  color: const Color(0xFFDC2626),
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownOpen = !isDropdownOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.selectedValues.isEmpty
                        ? widget.hintText
                        : widget.selectedValues
                        .map((e) => e.toString())
                        .join(", "),
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(isDropdownOpen
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (isDropdownOpen)
          Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: widget.items.map((item) {
                bool isSelected = widget.selectedValues.contains(item);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(item.toString()),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        widget.selectedValues.add(item);
                      } else {
                        widget.selectedValues.remove(item);
                      }
                      widget.onChanged(widget
                          .selectedValues); // Call the callback with updated values
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class CustomTextFormFieldWithLabel extends StatelessWidget {
  final String label;
  final String hintText;
  final int? minLines;
  final Color? fillColor;
  final TextEditingController controller;
  final String? Function(String?)? validator;


  const CustomTextFormFieldWithLabel({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.minLines,
    this.fillColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 5),
        DefaultTextFormField(
          controller: controller,
          hintText: hintText,
          minLines: minLines,
          fillColor: fillColor,
          validator: validator,
        ),
      ],
    );
  }
}

class DefaultTextFormField extends StatelessWidget {
  const DefaultTextFormField({super.key, required this.hintText, this.validator, required this.controller,  this.minLines, this.fillColor});
  final String hintText;
  final TextEditingController controller;
  final int? minLines ;
  final Color? fillColor ;
  final String? Function(String?)? validator;


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: minLines,
      maxLines: null,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:  TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 0.5,
            color: Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 0.5,
            color: Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        filled: true,
        fillColor: fillColor?? const Color(0xFFF9FAFB),
      ),
    );
  }
}

class DefaultButton extends StatelessWidget {
  DefaultButton(
      {super.key, required this.onPressed, required this.label, this.backgroundColor, this.textColor,});

  final Function() onPressed;
  final String label;

  Color? backgroundColor;
  Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: 16,
        ),
        backgroundColor: backgroundColor,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),

        ),
      ),
      onPressed: onPressed,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
              color: textColor
          ),
        ),
      ),
    );
  }
}