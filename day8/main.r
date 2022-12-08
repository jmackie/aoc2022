string_to_chars <- function(s) strsplit(s, "")

# Reads the input as a matrix of integers
read_input <- function(file) {
  lines <- read.table(file, colClasses = c("character"))
  process_line <- function(line) lapply(string_to_chars(line), strtoi)
  rows <- unlist(
    lapply(lines, process_line),
    recursive = FALSE, use.names = FALSE
  )
  do.call(rbind, rows)
}

look_left <- function(m, i, j) head(m[i, 1:j], -1)
look_right <- function(m, i, j) tail(m[i, j:ncol(m)], -1)
look_up <- function(m, i, j) head(m[1:i, j], -1)
look_down <- function(m, i, j) tail(m[i:nrow(m), j], -1)

part_one <- function(input) {
  is_visible <- function(x, i, j) {
    if (i %in% c(1, nrow(input)) || j %in% c(1, ncol(input))) {
      # if it's on the edge, it's visible
      return(TRUE)
    }

    trees_left <- look_left(input, i, j)
    trees_right <- look_right(input, i, j)
    trees_above <- look_up(input, i, j)
    trees_below <- look_down(input, i, j)

    visible_from_left <- all(trees_left < x)
    visible_from_right <- all(trees_right < x)
    visible_from_top <- all(trees_above < x)
    visible_from_bottom <- all(trees_below < x)

    any(
      visible_from_left,
      visible_from_right,
      visible_from_top,
      visible_from_bottom
    )
  }

  visibilities <- matrix(
    mapply(is_visible, input, row(input), col(input)),
    nrow = nrow(input)
  )
  sum(visibilities)
}

part_two <- function(input) {
  visible_trees <- function(trees, height, reverse = FALSE) {
    ntrees <- length(trees)
    if (ntrees == 0) {
      return(0)
    }

    which_blocking_trees <- which(trees >= height)
    if (length(which_blocking_trees) == 0) {
      return(ntrees)
    }

    if (reverse) {
      first_blocking_tree <- min(which_blocking_trees)
      length(trees[1:first_blocking_tree])
    } else {
      first_blocking_tree <- max(which_blocking_trees)
      length(trees[first_blocking_tree:length(trees)])
    }
  }

  scenic_score <- function(x, i, j) {
    trees_left <- look_left(input, i, j)
    visible_trees_left <- visible_trees(trees_left, x)

    trees_right <- look_right(input, i, j)
    visible_trees_right <- visible_trees(trees_right, x, TRUE)

    trees_above <- look_up(input, i, j)
    visible_trees_above <- visible_trees(trees_above, x)

    trees_below <- look_down(input, i, j)
    visible_trees_below <- visible_trees(trees_below, x, TRUE)

    prod(
      visible_trees_left,
      visible_trees_right,
      visible_trees_above,
      visible_trees_below
    )
  }

  scenic_scores <- matrix(
    mapply(scenic_score, input, row(input), col(input)),
    nrow = nrow(input)
  )
  max(scenic_scores)
}

main <- function(input_file) {
  input <- read_input(input_file)

  part_one_answer <- part_one(input)
  if (part_one_answer != 1719) {
    stop("wrong answer to part one")
  }
  cat("part one:", part_one_answer, "\n")

  part_two_answer <- part_two(input)
  if (part_two_answer != 590824) {
    stop("wrong answer to part two")
  }
  cat("part two:", part_two_answer, "\n")
}


main(commandArgs(TRUE)[1])
