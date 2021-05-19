#!/usr/bin/env R

# -----------------------------------------------------------------------------

# Copyright 2020 Mr. George L. Malone

# Written for the Australian National Phenome Centre, Murdoch University.
# Application source file for Shiny / Shiny Dashboard.

# Run this in an R session with the command `shiny::runApp(source_directory)`,
# and I recommend using the option `launch.browser = FALSE`, then navigating to
# the address provided in the console.

# Requires the following packages and all dependencies:
# - shiny
# - shinydashboard
# - visNetwork

# For the purpose of graph visualisation of metabolites present in the KEGG
# Compound database, via the KEGG REST API.

# Further development and refinement is required.  This is the first Shiny app
# I've made, and I am far from a proper developer.

# Some sections are commented out.  They're still in development, are due to be
# removed, or are currently invalid due to computational capability.

# As at the 11th of December, 2020:
# - Application now uses TSV storage, rather than one large RData object.
#   - This makes the whole thing *much* faster to calculate, but render time
#     for the graph is still relatively slow.
# - Upload preview and data preview have been separated.
# - All functions have been rewritten, and the function for cleaning chemical
#   names is now Mk. III.

# -----------------------------------------------------------------------------

#### Setup ####

pkg.vec <- c(
  "shiny",
  "shinydashboard",
  "visNetwork"
)
for (pkg in pkg.vec) {
  # if (!eval(bquote(require(.(pkg), quietly = TRUE)))) {
  if (!require(pkg, quietly = TRUE, character.only = TRUE)) {
    stop(paste0(pkg, " is required for the app to run!"))
  }
}

#### Header ####

header <- dashboardHeader(title = "KEGG Network")

#### Sidebar ####

sidebar.menu.item.main <- menuItem(
  "File upload",
  tabName = "main",
  icon = icon("upload")
)

sidebar.menu.item.dataSummary <- menuItem(
  "Data summary",
  tabName = "dataSummary",
  icon = icon("server")
)

sidebar.menu.item.visNetwork <- menuItem(
  "Network visualisation",
  tabName = "visNetwork",
  icon = icon("project-diagram")
)

sidebar.menu <- sidebarMenu(
  sidebar.menu.item.main,
  sidebar.menu.item.dataSummary,
  sidebar.menu.item.visNetwork
)

sidebar <- dashboardSidebar(sidebar.menu)

#### Body ####

tabitem.main.row1 <- fluidRow(
  box(
    fileInput(
      inputId = "fileUpload",
      label = "File upload",
      multiple = FALSE,
      buttonLabel = "Browse for file",
      placeholder = "No file selected",
      accept = ".tsv"
    ),
    tags$hr(),
    h4("Column indices"),
    splitLayout(
      HTML("<b>Chemical name:</b>"),
      numericInput(
        inputId = "dataColumnName",
        label = NULL,
        value = 1
      )
    ),
    splitLayout(
      HTML("<b>Regulation:</b>"),
      numericInput(
        inputId = "dataColumnReg",
        label = NULL,
        value = 2
      )
    ),
    splitLayout(
      HTML("<b>Header [y/n]:</b>"),
      checkboxInput(
        inputId = "ifHeader",
        label = NULL,
        width = "100%"
      )
    ),
    actionButton(
      inputId = "fileSubmit",
      label = "Submit file",
      width = "100%",
      icon = icon("file-upload")
    ),
    width = 4,
    status = "primary"
  ),
  uiOutput(outputId = "dataHeaderUI"),
  uiOutput(outputId = "infoBoxUI")
)

tabitem.main.row2 <- fluidRow(
  uiOutput(outputId = "uploadHeaderUI")
)

tabitem.main <- tabItem(
  tabName = "main",
  tabitem.main.row1,
  tabitem.main.row2
)

tabitem.dataSummary.row1 <- fluidRow(
  valueBoxOutput(outputId = "dataSummaryNumUpload"),
  valueBoxOutput(outputId = "dataSummaryNumUniq"),
  valueBoxOutput(outputId = "dataSummaryNumKegg")
)

tabitem.dataSummary.row2 <- fluidRow(
  valueBoxOutput(outputId = "dataSummaryNumNode"),
  valueBoxOutput(outputId = "dataSummaryNumDegZero"),
  valueBoxOutput(outputId = "dataSummaryMeanDeg")
)

tabitem.dataSummary <- tabItem(
  tabName = "dataSummary",
  tabitem.dataSummary.row1,
  tabitem.dataSummary.row2
)

# tabitem.visNetwork.row1 <- fluidRow(
#   box(
#     checkboxInput(
#       inputId = "plusNeighbours",
#       label = "Include neighbours (+1)",
#       width = "170px"
#     ),
#     status = "primary",
#     width = 4
#   )
# )

tabitem.visNetwork.row2 <- fluidRow(
  box(
    visNetworkOutput(
      outputId = "visNetwork",
      width = "100%",
      height = "600px"
    ),
    width = 12,
    height = "620px"
  )
)

tabitem.visNetwork <- tabItem(
  tabName = "visNetwork",
  # tabitem.visNetwork.row1,
  tabitem.visNetwork.row2
)

body.tabitems <- tabItems(
  tabitem.main,
  tabitem.dataSummary,
  tabitem.visNetwork
)

body <- dashboardBody(
  body.tabitems
)

#### Construction ####

ui <- dashboardPage(
  header,
  sidebar,
  body
)

server <- function(input, output) {
  dirDat <- "./coreData"
  dirSrc <- "./coreData/functions/"
  src <- c(
    "adjmatReduceNplus",
    "chemname_cleaner_mk03",
    "nameInKegg",
    "isomericReduction",
    "visNetworkInfo"
  )
  for (s in src) { source(paste0(dirSrc, s, ".R")) }
  load(file.path(dirDat, "adjmat.RData"))
  rfKeggidName = read.delim(
    file.path(dirDat, "rfKeggidName.tsv"),
    header = TRUE,
    sep = "\t",
    na.strings = '',
    stringsAsFactors = FALSE
  )
  nameSearchPrev = read.delim(
    file.path(dirDat, "nameSearchPrev.tsv"),
    header = TRUE,
    sep = "\t",
    na.strings = '',
    stringsAsFactors = FALSE
  )
  nameWithId = read.delim(
    file.path(dirDat, "nameWithId.tsv"),
    header = TRUE,
    sep = "\t",
    na.strings = '',
    stringsAsFactors = FALSE
  )
  rv <- reactiveValues(
    infoBox = NULL,
    tsv = NULL,
    vnOutput0 = NULL  #,
    # vnOutput1 = NULL
  )
  observeEvent(
    {
      input$fileSubmit
    },
    {
      output$infoBoxUI <- renderUI({
        box(
          verbatimTextOutput(
            outputId = "infoBox",
            placeholder = TRUE
          ),
          width = 4
        )
      })
      if (is.null(input$fileUpload)) {
        rv$infoBox <- append(rv$infoBox, "No file found.")
      } else {
        withProgress(
          message = "Processing data...",
          value = 0,
          {
            rv$infoBox <- rv$infoBox[which(rv$infoBox != "No file found.")]
            tsv <- read.delim(
              input$fileUpload$datapath,
              header = input$ifHeader,
              sep = "\t",
              na.strings = '',
              stringsAsFactors = FALSE
            )
            data <- tsv[, c(input$dataColumnName, input$dataColumnReg)]
            dataClean <- chemname_cleaner_mk03(data)
            rv$infoBox <- append(
              rv$infoBox,
              paste0(nrow(dataClean), " rows in cleaned data.")
            )
            output$dataSummaryNumUpload <- renderValueBox({
              valueBox(
                value = length(dataClean[, 1]),
                subtitle = "names in TSV input",
                color = "purple",
                icon = icon("list")
              )
            })
            rv$infoBox <- append(
              rv$infoBox,
              paste0(
                length(unique(dataClean[, 1])),
                " unique names in cleaned data."
              )
            )
            output$dataSummaryNumUniq <- renderValueBox({
              valueBox(
                value = length(unique(dataClean[, 1])),
                subtitle = "unique names in TSV input",
                color = "purple",
                icon = icon("list")
              )
            })
            setProgress(value = 0.25)
            notSearched <- !(dataClean[, 1] %in% nameSearchPrev[, 1])
            if (any(notSearched)) {
              toSearch <- dataClean[notSearched, 1]
              rv$infoBox <- append(
                rv$infoBox,
                paste0(length(toSearch), " new search terms found.\n")
              )
              nik <- nameInKegg(sort(unique(toSearch)), rfKeggidName)
              nameSearchPrev <- rbind(nameSearchPrev, nik)
              nameSearchPrev <- nameSearchPrev[order(nameSearchPrev[, 1]), ]
              write.table(
                nameSearchPrev,
                file = file.path(dirDat, "nameSearchPrev.tsv"),
                sep = "\t",
                eol = "\n",
                quote = FALSE,
                row.names = FALSE,
                na = ''
              )
              if (all(is.na(nik[, 2]))) {
                rv$infoBox <- append(
                  rv$infoBox,
                  "No new names found in KEGG Compound data.\n"
                )
              } else {
                found <- nik[which(!(is.na(nik[, 2]))), ]
                rv$infoBox <- append(
                  rv$infoBox,
                  paste0(
                    length(unique(found[, 1])),
                    " new names found in KEGG Compound data.\n"
                  )
                )
                foundReduced <- isomericReduction(found)
                nameWithId <- rbind(nameWithId, foundReduced)
                nameWithId <- nameWithId[order(nameWithId[, 1]), ]
                write.table(
                  nameWithId,
                  file = file.path(datDir, "nameWithId.tsv"),
                  sep = "\t",
                  eol = "\n",
                  quote = FALSE,
                  row.names = FALSE,
                  na = ''
                )
              }
            }
            rv$infoBox <- append(
              rv$infoBox,
              paste0("No new search terms found.")
            )
            setProgress(value = 0.5)
            listWithId <- lapply(
              sort(unique(dataClean[, 1])),
              function(x) { nameWithId[which(nameWithId[, 1] == x), ] }
            )
            withId <- NULL
            for (l in listWithId) { withId <- rbind(withId, l) }
            rownames(withId) <- NULL
            colnames(withId) <- c("name", "idKegg", "idOther")
            luwi <- length(unique(withId[, 2]))
            rv$infoBox <- append(
              rv$infoBox,
              paste0(
                ifelse(
                  luwi == 0,
                  "No names",
                  paste0(luwi, " unique input compounds")
                ),
                " found in KEGG Compound data.\n"
              )
            )
            output$dataSummaryNumKegg <- renderValueBox({
              valueBox(
                value = luwi,
                subtitle = "names in KEGG Compound",
                color = "purple",
                icon = icon("database")
              )
            })
            output$dataSummaryNumNode <- renderValueBox({
              valueBox(
                value = luwi,
                subtitle = "nodes in adjacency matrix",
                color = "purple",
                icon = icon("project-diagram")
              )
            })
            setProgress(value = 0.75)
            adjRed0 <- adjmatReduceNplus(adjmat, withId, n = 0)
            adjmatDeg <- apply(adjRed0, 1, sum)
            output$dataSummaryNumDegZero <- renderValueBox({
              valueBox(
                value = length(adjmatDeg[which(adjmatDeg == 0)]),
                subtitle = "nodes with degree zero",
                color = "purple",
                icon = icon("creative-commons-zero")
              )
            })
            output$dataSummaryMeanDeg <- renderValueBox({
              valueBox(
                value = round(mean(adjmatDeg), 2L),
                subtitle = "mean node degree",
                color = "purple",
                icon = icon("balance-scale")
              )
            })
            vnInf0 <- visNetworkInfo(
              dataClean,
              withId,
              adjRed0
            )
            # vnInf1 <- visNetworkInfo(
            #   dataClean,
            #   withId,
            #   rv$adjRed1
            # )
            rv$vnOutput0 <- visNetwork::visNetwork(
              nodes = vnInf0$nodes,
              edges = vnInf0$edges,
              width = "100%",
              height = "700px",
              background = rgb(1, 1, 1)
            )
            # rv$vnOutput1 <- visNetwork::visNetwork(
            #   nodes = vnInf1$nodes,
            #   edges = vnInf1$edges,
            #   width = "100%",
            #   height = "700px",
            #   background = rgb(1, 1, 1)
            # )
            setProgress(value = 1)
          }
        )
      }
    }
  )
  output$infoBox <- renderText({
    paste0(rv$infoBox, collapse = "\n")
  })
  observeEvent(
    {
      input$fileUpload
    },
    {
      rv$tsv <- read.delim(
        input$fileUpload$datapath,
        header = input$ifHeader,
        sep = "\t",
        na.strings = '',
        stringsAsFactors = FALSE
      )
      output$uploadHeaderUI <- renderUI({
        box(
          h4("Upload preview"),
          tags$hr(),
          tableOutput(outputId = "uploadHeader"),
          width = 12
        )
      })
      output$dataHeaderUI <- renderUI({
        box(
          h4("Data preview"),
          tags$hr(),
          tableOutput(outputId = "dataHeader"),
          width = 4,
          status = "warning"
        )
      })
    }
  )
  observeEvent(
    {
      input$ifHeader
    },
    {
      req(input$fileUpload)
      rv$tsv <- read.delim(
        input$fileUpload$datapath,
        header = input$ifHeader,
        sep = "\t",
        na.strings = '',
        stringsAsFactors = FALSE
      )
    }
  )
  output$uploadHeader <- renderTable({
    req(input$fileUpload)
    req(rv$tsv)
    if (ncol(rv$tsv) > 12) { cols <- 12 } else { cols <- ncol(rv$tsv) }
    head(rv$tsv[, 1:cols], 6L)
  })
  output$dataHeader <- renderTable({
    req(input$fileUpload)
    req(rv$tsv)
    head(
      rv$tsv[, c(input$dataColumnName, input$dataColumnReg)],
      6L
    )
  })
  # output$visNetwork <- renderVisNetwork({
  #   if (input$plusNeighbours) {
  #     rv$vnOutput1
  #   } else {
  #     rv$vnOutput0
  #   }
  # })
  output$visNetwork <- renderVisNetwork({
    rv$vnOutput0
  })
}

shinyApp(
  ui = ui,
  server = server
)
