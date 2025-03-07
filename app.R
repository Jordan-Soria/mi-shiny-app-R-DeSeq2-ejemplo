
ui = dashboardPage(
  dashboardHeader(title = "DESeq2: resultados"),
  dashboardSidebar(
    sidebarMenu(  # Necesario para manejar pestañas
      selectInput("fdr", label = "Cutoff for FDRs:", c("0.001" = 0.001, "0.01" = 0.01, "0.05" = 0.05)),
      numericInput("base_mean", label = "Minimal base mean:", value = 0),
      numericInput("log2fc", label = "Minimal abs(log2 fold change):", value = 0),
      actionButton("filter", label = "Generate heatmap"),
      menuItem("Heatmap Analysis", tabName = "heatmap", icon = icon("chart-bar")),  # Página principal
      menuItem("Paquetes de R", tabName = "second_page", icon = icon("file-alt"))  # Segunda página
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        /* Sobreescribir estilo del item activo en el sidebar para skin-red */
        .skin-red .main-sidebar .sidebar-menu > li.active > a {
          background-color: #ff66b2 !important;
          color: white !important;
        }
        .skin-red .main-sidebar .sidebar-menu > li.active > a:hover {
          background-color: #ff66b2 !important;
          color: white !important;
        }
        .skin-red .main-sidebar .sidebar-menu > li.active > a > i {
          color: white !important;
        }
        
        /* Mantener el estilo existente para el sidebar y contenido */
        .content-wrapper, .right-side {
          padding-left: 150px !important;
          margin-left: 0px !important;
        }
        .main-sidebar {
          width: 250px !important;
          background-color: #d9534f !important;
        }
        .content-wrapper {
          min-height: 100vh;
          padding-left: 125px !important;
        }
        .box {
          width: 100% !important;
        }
        .second-page-row {
          margin-left: 120px !important;
        }
      "))
    ),
    
    # Aquí agregamos el script de JavaScript para ocultar el sidebar en la segunda página
    tags$script(HTML("
      $(document).on('shiny:inputchanged', function(event) {
        if (event.name == 'sidebar-menu-item-clicked') {
          if (event.value == 'second_page') {
            // Ocultar el sidebar cuando se hace clic en la segunda página
            $('.main-sidebar').hide();
          } else {
            // Mostrar el sidebar cuando se hace clic en la primera página
            $('.main-sidebar').show();
          }
        }
      });
    ")),
    
    tabItems(
      tabItem(tabName = "heatmap", body),  # Página principal sin desplazamiento
      tabItem(tabName = "second_page",
              fluidRow(class = "second-page-row",  # Añadimos la clase aquí
                       column(width = 12,
                              box(title = "CÓMO MOSTRAR DATOS DE DESEQ2 EN R MÁS BONITO...", width = NULL, solidHeader = TRUE, status = "primary",
                                  h3("Paquetes de R usados para crear este Dashboard:"),  
                                  p("library(c('DT','Shiny','Shinydashboard', 'ComplexHeatmap',...))"),
                                  p("Uso de datos propios para elaborarlo")
                              )
                       )
              )
      )
    )
  ),
  
  skin = "red"
)

server = function(input, output, session) {
  observeEvent(input$filter, {
    ht = make_heatmap(fdr = as.numeric(input$fdr), base_mean = input$base_mean, log2fc = input$log2fc)
    if(!is.null(ht)) {
      makeInteractiveComplexHeatmap(input, output, session, ht, "ht",
                                    brush_action = brush_action)
    } else {
      output$ht_heatmap = renderPlot({
        grid.newpage()
        grid.text("No row exists after filtering.")
      })
    }
  }, ignoreNULL = FALSE)
}

shinyApp(ui, server)
