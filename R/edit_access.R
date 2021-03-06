#' Shiny App for editing the metadata access table

#' @param filepath the filepath leading to the access.csv file
#' @param outdir The directory to save the edited access info to
#' @param outfilename The filename to save with. Defaults to access.csv.
#'
#' @import shiny
#' @import rhandsontable
#' @export
#'
#' @examples
#' \dontrun{
#' editTable(DF = access)
#'
#'}

edit_access <- function(filepath="metadata-tables/access.csv",
                         outdir=getwd(),
                         outfilename="access"){
  ui <- shinyUI(fluidPage(

    titlePanel("Populate the Access Metadata Table"),
    sidebarLayout(
      sidebarPanel(
        helpText("Shiny app to read in the dataspice metadata templates and populate with usersupplied data"),
        # fileName	name	contentUrl	fileFormat

        h6('fileName = the filename of the input data file(s). Do Not Change.'),
        h6("variableName = the human readable name of the measured variable."),
        h6('contentUrl = a url from where that data came, if applicable'),
        h6("fileFormat = the file format. Do Not. Change"),

        br(),

        wellPanel(
          h3("Save table"),
          div(class='row',
              div(class="col-sm-6",
                  actionButton("save", "Save"))
          )
        )

      ),

      mainPanel(
        wellPanel(
          uiOutput("message", inline=TRUE)
        ),
        rHandsontableOutput("hot"),
        br()

      )
    )
  ))

  server <- shinyServer(function(input, output) {

    values <- reactiveValues()
    
    dat <- read_csv(file = filepath,
                    col_types = "cccc")

    output$hot <- renderRHandsontable({

      rhandsontable(dat,
                    useTypes = FALSE,
                    stretchH = "all")
    })

    ## Save
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      utils::write.csv(finalDF, file=file.path(outdir,
                                        sprintf("%s.csv", outfilename)),
                row.names = FALSE)
    })

    ## Message
    output$message <- renderUI({
      if(input$save==0){
        helpText(sprintf("This table will be saved in folder \"%s\" once you press the Save button.", outdir))
      }else{
        outfile <- "access.csv"
        fun <- 'read.csv'
        list(helpText(sprintf("File saved: \"%s\".",
                              file.path(outdir, outfile))),
             helpText(sprintf("Type %s(\"%s\") to get it.",
                              fun, outfile)))
      }
    })

  })

  ## run app
  runApp(list(ui=ui, server=server))
  return(invisible())
}
