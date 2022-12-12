import scala.io.Source
import scala.annotation.tailrec
import scala.collection.mutable

object Aoc {
  case class DirectedEdge(from: Int, to: Int, weight: Double = 1.0) {
    override def toString(): String = s"$from -> $to"
  }

  case class EdgeWeightedDigraph(
      adj: Map[Int, List[DirectedEdge]] = Map.empty
  ) {
    def addEdge(edge: DirectedEdge): EdgeWeightedDigraph = {
      val list = this.adj.getOrElse(edge.from, List.empty)
      val adj = this.adj + (edge.from -> (list :+ edge))
      EdgeWeightedDigraph(adj)
    }
  }

  object ShortestPath {
    def run(
        graph: EdgeWeightedDigraph,
        start: Int
    ): Either[String, ShortestPathCalc] = {
      val size = graph.adj.size

      if (start >= size) Left(s"Source vertex must in range [0, $size)")
      else {
        val edgeTo = mutable.ArrayBuffer.fill[Option[DirectedEdge]](size)(None)
        val distTo = mutable.ArrayBuffer.fill(size)(Double.PositiveInfinity)

        distTo(start) = 0.0

        val sourceDist = (start, distTo(start))
        val sortByWeight: Ordering[(Int, Double)] = (a, b) =>
          a._2.compareTo(b._2)

        val queue =
          mutable.PriorityQueue[(Int, Double)](sourceDist)(sortByWeight)

        while (queue.nonEmpty) {
          val (minDestV, _) = queue.dequeue()
          val edges = graph.adj.getOrElse(minDestV, List.empty)

          edges.foreach { e =>
            if (distTo(e.to) > distTo(e.from) + e.weight) {
              distTo(e.to) = distTo(e.from) + e.weight
              edgeTo(e.to) = Some(e)
              if (!queue.exists(_._1 == e.to))
                queue.enqueue((e.to, distTo(e.to)))
            }
          }
        }
        Right(new ShortestPathCalc(edgeTo.toSeq, distTo.toSeq))
      }
    }
  }

  class ShortestPathCalc(
      edgeTo: Seq[Option[DirectedEdge]],
      distTo: Seq[Double]
  ) {
    def pathTo(v: Int): Either[String, Seq[DirectedEdge]] = {
      @tailrec
      def go(list: List[DirectedEdge], vv: Int): List[DirectedEdge] =
        edgeTo(vv) match {
          case Some(e) => go(e +: list, e.from)
          case None    => list
        }

      hasPath(v).map(b => if (!b) Seq() else go(List(), v))
    }

    def hasPath(v: Int): Either[String, Boolean] =
      distTo
        .lift(v)
        .map(_ < Double.PositiveInfinity)
        .toRight(s"Vertex $v does not exist")

    def distToV(v: Int): Either[String, Double] =
      distTo.lift(v).toRight(s"Vertex $v does not exist")
  }

  val aElevation = 'a'.toInt
  def charToElevation(c: Char): Int = c match {
    case 'S' => charToElevation('a')
    case 'E' => charToElevation('z')
    case _   => c - aElevation
  };

  type Grid = Seq[Seq[Char]]

  def mkGridIndex(row: Int, col: Int, ncol: Int): Int = (row * ncol) + col

  def getEdges(
      grid: Grid,
      row: Int,
      col: Int
  ): Array[DirectedEdge] = {
    val nrow = grid.length
    val ncol = grid(0).length

    val from = mkGridIndex(row = row, col = col, ncol = ncol)

    val elevation = charToElevation(grid(row)(col))

    var edges: Array[DirectedEdge] = Array.empty

    // The destination square can be at most one higher than the elevation of your current square.
    // This also means that the elevation of the destination square can be much lower
    // than the elevation of your current square.

    val upRow = row - 1
    if (upRow >= 0) {
      val up = charToElevation(grid(upRow)(col))
      val diff = up - elevation
      if (diff <= 1)
        edges :+= DirectedEdge(
          from = from,
          to = mkGridIndex(row = upRow, col = col, ncol = ncol)
        )
    }

    val downRow = row + 1
    if (downRow < nrow) {
      val down = charToElevation(grid(downRow)(col))
      val diff = down - elevation
      if (diff <= 1)
        edges :+= DirectedEdge(
          from = from,
          to = mkGridIndex(row = downRow, col = col, ncol = ncol)
        )
    }

    val leftCol = col - 1
    if (leftCol >= 0) {
      val left = charToElevation(grid(row)(leftCol))
      val diff = left - elevation
      if (diff <= 1)
        edges :+= DirectedEdge(
          from = from,
          to = mkGridIndex(row = row, col = leftCol, ncol = ncol)
        )
    }

    val rightCol = col + 1
    if (rightCol < ncol) {
      val right = charToElevation(grid(row)(rightCol))
      val diff = right - elevation
      if (diff <= 1)
        edges :+= DirectedEdge(
          from = from,
          to = mkGridIndex(row = row, col = rightCol, ncol = ncol)
        )
    }

    edges

  }

  def buildInputGraph(grid: Grid): EdgeWeightedDigraph = {
    val graph = EdgeWeightedDigraph(
      grid.flatten.indices
        .foldLeft[Map[Int, List[DirectedEdge]]](Map.empty)({ (m, i) =>
          m + (i -> List.empty)
        })
    )

    grid.zipWithIndex.foldLeft(graph)({ (g, x) =>
      val (row, rowIndex) = x
      row.zipWithIndex
        .foldLeft(g)({ (gg, y) =>
          val (char, colIndex) = y
          if (char == 'E') gg
          else
            getEdges(grid, row = rowIndex, col = colIndex).foldLeft(gg)(
              _.addEdge(_)
            )
        })
    })
  }

  def partOne(inputFile: String): Int = {
    val inputLines = Source.fromFile(inputFile).getLines()
    val grid: Grid = inputLines.map(_.toSeq).toSeq
    val start = grid.flatten.indexWhere(_ == 'S')
    val end = grid.flatten.indexWhere(_ == 'E')

    val graph = buildInputGraph(grid);
    val shortest = ShortestPath.run(graph, start).toOption.get
    val path = shortest.pathTo(end).toOption.get
    path.length
  }

  def partTwo(inputFile: String): Int = {
    val inputLines = Source.fromFile(inputFile).getLines()
    val grid: Grid = inputLines.map(_.toSeq).toSeq

    val starts = grid.flatten.zipWithIndex.flatMap({ case (char, i) =>
      if (charToElevation(char) == 0) Some(i) else None
    })
    val end = grid.flatten.indexWhere(_ == 'E')

    val graph = buildInputGraph(grid);
    starts
      .flatMap(start => {
        val shortest = ShortestPath.run(graph, start).toOption.get
        val path = shortest.pathTo(end).toOption.get
        if (path.isEmpty) None else Some(path.length)
      })
      .min
  }

  def main(args: Array[String]) = {
    val inputFile = args(0)

    val partOneAnswer = partOne(inputFile)
    assert(partOneAnswer == 339, "wrong answer to part one")
    println(s"part one: $partOneAnswer")

    val partTwoAnswer = partTwo(inputFile)
    assert(partTwoAnswer == 332, "wrong answer to part two")
    println(s"part two: $partTwoAnswer")
  }
}
