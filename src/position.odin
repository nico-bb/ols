package main

import "core:strings"
import "core:unicode/utf8"
import "core:fmt"

/*
    This file handles the conversion between utf-16 and utf-8 offsets in the text document
 */


AbsoluteRange :: struct {
    start: int,
    end: int,
};

get_absolute_range :: proc(range: Range, document_text: [] u8) -> (AbsoluteRange, bool) {

    absolute: AbsoluteRange;

    if len(document_text) <= 2 {
        return absolute, false;
    }

    line_count := 0;
    index := 1;
    last := document_text[0];

    if !get_index_at_line(&index, &line_count, &last, document_text, range.start.line) {
        return absolute, false;
    }

    absolute.start = index + get_character_offset_u16_to_u8(range.start.character, document_text[index:]);

    if !get_index_at_line(&index, &line_count, &last, document_text, range.end.line) {
        return absolute, false;
    }

    absolute.end = index + get_character_offset_u16_to_u8(range.end.character, document_text[index:]);

    return absolute, true;
}


get_index_at_line :: proc(current_index: ^int, current_line: ^int, last: ^u8, document_text: []u8, end_line: int) -> bool {

    if current_line^ == end_line {
        return true;
    }

    for ; current_index^ < len(document_text); current_index^ += 1 {

        current := document_text[current_index^];

        if last^ == '\r' {
            current_line^ += 1;

            if current_line^ == end_line {
                last^ = current;
                current_index^ += 1;
                return true;
            }

        }

        else if current == '\n' {
            current_line^ += 1;

            if current_line^ == end_line {
                last^ = current;
                current_index^ += 1;
                return true;
            }

        }

        last^ = document_text[current_index^];
    }

    return false;

}

get_character_offset_u16_to_u8 :: proc(character_offset: int, document_text: [] u8) -> int {

    utf8_idx := 0;
    utf16_idx := 0;

    fmt.println(character_offset);

    for utf16_idx < character_offset {

        r, w := utf8.decode_rune(document_text[utf8_idx:]);

        if r < 0x10000 {
            utf16_idx += 1;
        }

        else {
            utf16_idx += 2;
        }

        utf8_idx += w;

    }

    return utf8_idx;
}