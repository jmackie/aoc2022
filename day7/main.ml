module Fs : sig
  type file = { name : string; size : int }

  type tree = Dir of dir | File of file
  and dir = { name : string; size : int; children : tree list }

  val size : tree -> int
  val print : int -> tree -> unit
end = struct
  type file = { name : string; size : int }

  type tree = Dir of dir | File of file
  and dir = { name : string; size : int; children : tree list }

  let size = function Dir { size } -> size | File { size } -> size
  let rec mk_indent n = if n = 0 then "" else " " ^ mk_indent (n - 1)

  (* for debuggin *)
  let rec print (indent : int) = function
    | Dir { name; children } ->
        print_endline (mk_indent indent ^ "- " ^ name ^ " (dir)");
        List.iter (print (indent + 2)) children
    | File { name; size } ->
        print_endline
          (mk_indent indent ^ Printf.sprintf "- %s (file, size=%d)" name size)
end

type dir = Root | Dir of string | Parent
type cmd = Cd of dir | Ls
type ls_output = LsFile of Fs.file | LsDir of string
type input_line = Cmd of cmd | LsOutput of ls_output

let parse_input_line (line : string) : input_line option =
  match String.split_on_char ' ' line with
  | [ "$"; "ls" ] -> Some (Cmd Ls)
  | [ "$"; "cd"; "/" ] -> Some (Cmd (Cd Root))
  | [ "$"; "cd"; ".." ] -> Some (Cmd (Cd Parent))
  | [ "$"; "cd"; dir ] -> Some (Cmd (Cd (Dir dir)))
  | [ "dir"; dir ] -> Some (LsOutput (LsDir dir))
  | [ size_string; name ] -> (
      try
        let size = int_of_string size_string in
        Some (LsOutput (LsFile { name; size }))
      with _ -> None)
  | _ -> None

exception MalformedInput

type input = input_line Stream.t

let stream_input (file_name : string) : input =
  let in_channel = open_in file_name in
  Stream.from (fun _i ->
      try
        let line = input_line in_channel in
        match parse_input_line line with
        | None -> raise MalformedInput
        | parsed -> parsed
      with
      | End_of_file ->
          let () = close_in in_channel in
          None
      | exn ->
          let () = close_in in_channel in
          raise exn)

let rec collect_files (accum : Fs.file list) (input : input) : Fs.file list =
  match Stream.peek input with
  | None -> accum
  | Some (Cmd _) -> accum
  | Some (LsOutput output) -> (
      let () = Stream.junk input in
      match output with
      | LsFile file -> collect_files (file :: accum) input
      | LsDir _ -> collect_files accum input)

let rec build_fs_tree (input : input) : Fs.tree list =
  match Stream.peek input with
  | None -> []
  | Some _ -> (
      match Stream.next input with
      | Cmd Ls ->
          let files = List.map (fun f -> Fs.File f) (collect_files [] input) in
          List.append files (build_fs_tree input)
      | Cmd (Cd (Dir name)) ->
          let children = build_fs_tree input in
          let size =
            List.fold_left (fun sum tree -> sum + Fs.size tree) 0 children
          in
          Fs.Dir { name; size; children } :: build_fs_tree input
      | Cmd (Cd Parent) -> []
      | Cmd (Cd Root) -> raise MalformedInput
      | LsOutput _ ->
          raise MalformedInput (* should be consumed by `collect_files` *))

let input_to_fs_tree (input : input) : Fs.tree =
  match Stream.next input with
  | Cmd (Cd Root) ->
      let children = build_fs_tree input in
      let size =
        List.fold_left (fun sum tree -> sum + Fs.size tree) 0 children
      in
      Fs.Dir { name = "/"; size; children }
  | _ -> raise MalformedInput

let read_input_to_fs (input_file_name : string) : Fs.tree =
  input_to_fs_tree (stream_input input_file_name)

let sum = List.fold_left ( + ) 0

let part_one (tree : Fs.tree) : int =
  let is_small size = size <= 100000 in
  let rec get_small_dir_sizes = function
    | Fs.File _ -> []
    | Fs.Dir { size; children } ->
        let small_dirs = List.concat_map get_small_dir_sizes children in
        if is_small size then size :: small_dirs else small_dirs
  in
  sum (get_small_dir_sizes tree)

let list_min =
  List.fold_left
    (fun x_option y ->
      match x_option with None -> Some y | Some x -> Some (min x y))
    None

let part_two (tree : Fs.tree) : int =
  let total_disc_space = 70000000 in
  let unused_disc_space = total_disc_space - Fs.size tree in
  let required_unused_disc_space = 30000000 in
  let space_needed = required_unused_disc_space - unused_disc_space in

  let could_delete size = size >= space_needed in
  let rec find_deletion_candidates = function
    | Fs.File _ -> []
    | Fs.Dir { size; children } ->
        if could_delete size then
          size :: List.concat_map find_deletion_candidates children
        else []
  in
  Option.get (list_min (find_deletion_candidates tree))

let main (input_file_name : string) =
  let tree = read_input_to_fs input_file_name in

  let part_one_answer = part_one tree in
  let () = assert (part_one_answer == 1454188) in
  let () = Printf.printf "part one: %d\n" part_one_answer in

  let part_two_answer = part_two tree in
  let () = assert (part_two_answer == 4183246) in
  let () = Printf.printf "part two: %d\n" part_two_answer in

  ()
;;

main (Array.get Sys.argv 1)
