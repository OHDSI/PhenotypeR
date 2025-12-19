ui <- fluidPage(
  bslib::page_navbar(
    theme = bs_theme(5, "pulse"),
    navbar_options =list(class = "bg-dark", theme = "dark"),

    title = "PhenotypeR",

    bslib::nav_panel(title = "Background",
                     icon = shiny::icon("disease"),
                     shiny::includeMarkdown(path = "background.md")),

    # databaseDiagnostics_start -----
    bslib::nav_menu(
      title = "Database diagnostics",
      icon = shiny::icon("list"),
      ## snapshot -----
      bslib::nav_panel(
        title = "Snapshot",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_omop_snapshot_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_name,
                    choices = choices$shared_cdm_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateSnapshot", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("clipboard-list"),
        bslib::card(
          full_screen = TRUE,
          bslib::card_header(
            shiny::downloadButton(outputId = "summarise_omop_snapshot_gt_download", label = ""),
            class = "text-end"
          ),
          gt::gt_output("summarise_omop_snapshot_gt") |> withSpinner()
        )
      ),
      ## observation periods -----
      bslib::nav_panel(
        title = "Observation periods",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_observation_period_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_name,
                    choices = choices$shared_cdm_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateObservationPeriod", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("eye"),
        bslib::nav_panel(
          title = "Table observation period",
          bslib::card(
            full_screen = TRUE,
            bslib::card_header(
              shiny::downloadButton(outputId = "summarise_observation_period_gt_download", label = ""),
              class = "text-end"
            ),
            gt::gt_output("summarise_observation_period_gt") |> withSpinner()
          )
        )
      )
    ),
    # databaseDiagnostics_end ----
    # codelistDiagnostics_start -----
    bslib::nav_menu(
      title = "Codelist diagnostics",
      icon = shiny::icon("list"),
      ## achilles_results_start
      ## achilles code use -----
      bslib::nav_panel(
        title = "Achilles code use",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "achilles_code_use_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_name,
                    choices = choices$shared_cdm_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateAchillesCodeUse", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("database"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "achilles_code_use_codelist_name",
                                         label = "Codelist name",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       div(style="display: flex; justify-content: space-between;",
                                           div(style="flex: 1;", prettyCheckbox(inputId = "achilles_person_count",
                                                                                label = "Person count",
                                                                                value = TRUE,
                                                                                status = "primary",
                                                                                shape = "curve",
                                                                                outline = TRUE)),
                                           div(style="flex: 1;", prettyCheckbox(inputId = "achilles_record_count",
                                                                                label = "Record count",
                                                                                value = TRUE,
                                                                                status = "primary",
                                                                                shape = "curve",
                                                                                outline = TRUE))
                                       )
                                     ),
                                     bslib::accordion_panel(
                                       title = "Table formatting",
                                       materialSwitch(inputId = "achilles_interactive",
                                                      value = TRUE,
                                                      label = "Interactive",
                                                      status = "primary"),
                                       sortable::bucket_list(
                                         header = NULL,
                                         sortable::add_rank_list(
                                           text = "none",
                                           labels = c("codelist_name"),
                                           input_id = "achilles_code_use_none"
                                         ),
                                         sortable::add_rank_list(
                                           text = "header",
                                           labels = c("cdm_name", "estimate_name"),
                                           input_id = "achilles_code_use_header"
                                         ),
                                         sortable::add_rank_list(
                                           text = "groupColumn",
                                           labels = character(),
                                           input_id = "achilles_code_use_groupColumn"
                                         ),
                                         sortable::add_rank_list(
                                           text = "hide",
                                           labels = character(),
                                           input_id = "achilles_code_use_hide"
                                         )
                                       )
                                     )
                                   )
          ),
          bslib::nav_panel(
            title = "achilles_code_use",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(
                shiny::downloadButton(outputId = "achilles_code_use_download", label = ""),
                class = "text-end"
              ),
              uiOutput("achilles_code_use_tbl") |> withSpinner()
            )
          )
        )
      ),
      ## unmapped concepts -----
      # bslib::nav_panel(
      #   title = "Unmapped concepts",
      #   icon = shiny::icon("database"),
      #   bslib::layout_sidebar(
      #     sidebar = bslib::sidebar(width = 400, open = "closed",
      #                              bslib::accordion(
      #                                bslib::accordion_panel(
      #                                  title = "Settings",
      #                                  shinyWidgets::pickerInput(
      #                                    inputId = "unmapped_cdm_name",
      #                                    label = "Database",
      #                                    choices = NULL,
      #                                    selected = NULL,
      #                                    multiple = TRUE,
      #                                    options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
      #                                  ),
      #                                  shinyWidgets::pickerInput(
      #                                    inputId = "unmapped_codelist_name",
      #                                    label = "Codelist name",
      #                                    choices = NULL,
      #                                    selected = NULL,
      #                                    multiple = TRUE,
      #                                    options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
      #                                  )
      #                                ),
      #                                bslib::accordion_panel(
      #                                  title = "Table formatting",
      #                                  sortable::bucket_list(
      #                                    header = NULL,
      #                                    sortable::add_rank_list(
      #                                      text = "none",
      #                                      labels = c( "codelist_name"),
      #                                      input_id = "unmapped_none"
      #                                    ),
      #                                    sortable::add_rank_list(
      #                                      text = "header",
      #                                      labels = c("cdm_name", "estimate_name"),
      #                                      input_id = "unmapped_header"
      #                                    ),
      #                                    sortable::add_rank_list(
      #                                      text = "groupColumn",
      #                                      labels = NULL,
      #                                      input_id = "unmapped_groupColumn"
      #                                    ),
      #                                    sortable::add_rank_list(
      #                                      text = "hide",
      #                                      labels = character(),
      #                                      input_id = "unmapped_hide"
      #                                    )
      #                                  )
      #                                )
      #                              )
      #     ),
      #     bslib::nav_panel(
      #       title = "Unmapped",
      #         bslib::card(
      #           full_screen = TRUE,
      #           bslib::card_header(
      #             bslib::popover(
      #               shiny::icon("download"),
      #               shinyWidgets::pickerInput(
      #                 inputId = "unmapped_formatted_download_type",
      #                 label = "File type",
      #                 selected = "docx",
      #                 choices = c("docx", "png", "pdf", "html"),
      #                 multiple = FALSE
      #               ),
      #               shiny::downloadButton(outputId = "unmapped_formatted_download", label = "Download")
      #             ),
      #             class = "text-end"
      #           ),
      #           gt::gt_output("unmapped_formatted") |> withSpinner()
      #         )
      #     )
      #   )
      # ),
      ## Orphan codes -----
      bslib::nav_panel(
        title = "Orphan codes",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"), # Explicitly use tags$label
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "orphan_code_use_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_name,
                    choices = choices$shared_cdm_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateOrphanCodeUse", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("circle-half-stroke"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "orphan_code_use_codelist_name",
                                         label = "Codelist name",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       div(style="display: flex; justify-content: space-between;",
                                           div(style="flex: 1;", prettyCheckbox(inputId = "orphan_person_count",
                                                                                label = "Person count",
                                                                                value = TRUE,
                                                                                status = "primary",
                                                                                shape = "curve",
                                                                                outline = TRUE)),
                                           div(style="flex: 1;", prettyCheckbox(inputId = "orphan_record_count",
                                                                                label = "Record count",
                                                                                value = TRUE,
                                                                                status = "primary",
                                                                                shape = "curve",
                                                                                outline = TRUE))
                                       )
                                     ),
                                     bslib::accordion_panel(
                                       title = "Table formatting",
                                       materialSwitch(inputId = "orphan_interactive",
                                                      value = TRUE,
                                                      label = "Interactive",
                                                      status = "primary"),
                                       sortable::bucket_list(
                                         header = NULL,
                                         sortable::add_rank_list(
                                           text = "none",
                                           labels = c("variable_name", "cohort_name", "variable_level"),
                                           input_id = "orphan_codes_gt_none"
                                         ),
                                         sortable::add_rank_list(
                                           text = "header",
                                           labels = c("cdm_name", "estimate_name"),
                                           input_id = "orphan_codes_gt_header"
                                         ),
                                         sortable::add_rank_list(
                                           text = "groupColumn",
                                           labels = character(),
                                           input_id = "orphan_codes_gt_groupColumn"
                                         ),
                                         sortable::add_rank_list(
                                           text = "hide",
                                           labels = character(),
                                           input_id = "orphan_codes_gt_hide"
                                         )
                                       )
                                     )
                                   )
          ),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header(
              shiny::downloadButton(outputId = "orphan_codes_download", label = ""),
              class = "text-end"
            ),
            uiOutput("orphan_codes_tbl") |> withSpinner()
          )
        )
      ),
      ## achilles_results_end
      ## Cohort code use -----
      bslib::nav_panel(
        title = "Cohort code use",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "cohort_code_use_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_name,
                    choices = choices$shared_cdm_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "cohort_code_use_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_name,
                    choices = choices$shared_cohort_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateCohortCodeUse", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("chart-column"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "cohort_code_use_domain_id",
                                         label = "Domain",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       div(style="display: flex; justify-content: space-between;",
                                           div(style="flex: 1;", prettyCheckbox(inputId = "cohort_code_use_person_count",
                                                                                label = "Person count",
                                                                                value = TRUE,
                                                                                status = "primary",
                                                                                shape = "curve",
                                                                                outline = TRUE)),
                                           div(style="flex: 1;", prettyCheckbox(inputId = "cohort_code_use_record_count",
                                                                                label = "Record count",
                                                                                value = TRUE,
                                                                                status = "primary",
                                                                                shape = "curve",
                                                                                outline = TRUE))
                                       )
                                     ),
                                     bslib::accordion_panel(
                                       title = "Table formatting",
                                       materialSwitch(inputId = "cohort_code_use_interactive",
                                                      value = TRUE,
                                                      label = "Interactive",
                                                      status = "primary"),
                                       sortable::bucket_list(
                                         header = NULL,
                                         sortable::add_rank_list(
                                           text = "none",
                                           labels = c("cohort_name", "codelist_name", "source_concept_name", "source_concept_id", "variable_name", "variable_level"),
                                           input_id = "cohort_code_use_gt_none"
                                         ),
                                         sortable::add_rank_list(
                                           text = "header",
                                           labels = c("cdm_name", "estimate_name"),
                                           input_id = "cohort_code_use_gt_header"
                                         ),
                                         sortable::add_rank_list(
                                           text = "groupColumn",
                                           labels =  character(),
                                           input_id = "cohort_code_use_gt_groupColumn"
                                         ),
                                         sortable::add_rank_list(
                                           text = "hide",
                                           labels = c("diagnostic", "phenotyper_version",
                                                      "domain_id", "timing"),
                                           input_id = "cohort_code_use_gt_hide"
                                         )
                                       )
                                     )
                                   )
          ),
          bslib::nav_panel(
            title = "Table cohort code use",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(
                shiny::downloadButton(outputId = "cohort_code_use_download", label = ""),
                class = "text-end"
              ),
              uiOutput("cohort_code_use_tbl") |> withSpinner()
            )
          )
        )
      ),
      ## measurement_diagnostics_start
      ## Measurement code use -----
      bslib::nav_panel(
        title = "Measurements Code Use",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "measurement_timings_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_name,
                    choices = choices$shared_cdm_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "measurement_timings_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_name,
                    choices = choices$shared_cohort_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateMeasurementCodeUse", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("weight-scale"),
        bslib::navset_card_tab(
          bslib::nav_panel(
            title = "Table Values (Concepts)",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(
                shiny::downloadButton(outputId = "measurement_value_as_concept_gt_download", label = ""),
                class = "text-end"
              ),
              bslib::layout_sidebar(
                sidebar = bslib::sidebar(width = 400, open = "closed",
                                         sortable::bucket_list(
                                           header = "Table formatting",
                                           sortable::add_rank_list(
                                             text = "none",
                                             labels = c("cohort_name", "variable_level",  "estimate_name"),
                                             input_id = "measurement_value_as_concept_gt_none"
                                           ),
                                           sortable::add_rank_list(
                                             text = "header",
                                             labels = c("cdm_name"),
                                             input_id = "measurement_value_as_concepts_gt_header"
                                           ),
                                           sortable::add_rank_list(
                                             text = "groupColumn",
                                             labels =  c("codelist_name"),
                                             input_id = "measurement_value_as_concept_gt_groupColumn"
                                           ),
                                           sortable::add_rank_list(
                                             text = "hide",
                                             labels =  c("variable_name"),
                                             input_id = "measurement_value_as_concept_gt_hide"
                                           )
                                         ),
                                         position = "right"
                ),
                gt::gt_output("measurement_value_as_concept_tbl") |> withSpinner()
              )
            )
          ),
          bslib::nav_panel(
            title = "Plot Values (Concepts)",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(
                bslib::popover(
                  shiny::icon("download"),
                  shiny::numericInput(
                    inputId = "plot_measurement_value_as_concept_download_width",
                    label = "Width",
                    value = 15
                  ),
                  shiny::numericInput(
                    inputId = "plot_measurement_value_as_concept_download_height",
                    label = "Height",
                    value = 10
                  ),
                  shinyWidgets::pickerInput(
                    inputId = "plot_measurement_value_as_concept_download_units",
                    label = "Units",
                    selected = "cm",
                    choices = c("px", "cm", "inch"),
                    multiple = FALSE
                  ),
                  shiny::numericInput(
                    inputId = "plot_measurement_value_as_concept_download_dpi",
                    label = "dpi",
                    value = 300
                  ),
                  shiny::downloadButton(outputId = "plot_measurement_value_as_concept_download", label = "Download")
                ),
                class = "text-end"
              ),
              bslib::layout_sidebar(
                sidebar = bslib::sidebar(width = 400, open = "closed",
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_value_as_concept_x",
                                           label = "Horizontal axis",
                                           selected = c("count"),
                                           multiple = FALSE,
                                           choices = c("count", "percentage"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_value_as_concept_y",
                                           label = "Vertical axis",
                                           selected = c("codelist_name"),
                                           multiple = FALSE,
                                           choices = c("count", "variable_level", "codelist_name", "concept_name", "cdm_name"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_value_as_concept_colour",
                                           label = "Colour",
                                           selected = c("concept_name", "variable_level"),
                                           multiple = TRUE,
                                           choices = c("count", "variable_level", "codelist_name", "concept_name", "cdm_name"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_value_as_concept_facet",
                                           label = "Facet",
                                           selected = c("cdm_name"),
                                           multiple = TRUE,
                                           choices = c("count", "variable_level", "codelist_name", "concept_name", "cdm_name"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         position = "right"
                ),
                shiny::plotOutput("plot_measurement_value_as_concept")
              )
            )
          ),
          bslib::nav_panel(
            title = "Table Values (Numeric)",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(
                shiny::downloadButton(outputId = "measurement_value_as_numeric_gt_download", label = ""),
                class = "text-end"
              ),
              bslib::layout_sidebar(
                sidebar = bslib::sidebar(width = 400, open = "closed",
                                         sortable::bucket_list(
                                           header = "Table formatting",
                                           sortable::add_rank_list(
                                             text = "none",
                                             labels = c("cohort_name", "estimate_name"),
                                             input_id = "measurement_value_as_numeric_gt_none"
                                           ),
                                           sortable::add_rank_list(
                                             text = "header",
                                             labels = c("cdm_name"),
                                             input_id = "measurement_value_as_numeric_gt_header"
                                           ),
                                           sortable::add_rank_list(
                                             text = "groupColumn",
                                             labels =  c("codelist_name"),
                                             input_id = "measurement_value_as_numeric_gt_groupColumn"
                                           ),
                                           sortable::add_rank_list(
                                             text = "hide",
                                             labels =  c("variable_name", "variable_level"),
                                             input_id = "measurement_value_as_numeric_gt_hide"
                                           )
                                         ),
                                         position = "right"
                ),
                gt::gt_output("measurement_value_as_numeric_tbl") |> withSpinner()
              )
            )
          ),
          bslib::nav_panel(
            title = "Plot Values (Numeric)",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(
                bslib::popover(
                  shiny::icon("download"),
                  shiny::numericInput(
                    inputId = "plot_measurement_value_as_numeric_download_width",
                    label = "Width",
                    value = 15
                  ),
                  shiny::numericInput(
                    inputId = "plot_measurement_value_as_numeric_download_height",
                    label = "Height",
                    value = 10
                  ),
                  shinyWidgets::pickerInput(
                    inputId = "plot_measurement_value_as_numeric_download_units",
                    label = "Units",
                    selected = "cm",
                    choices = c("px", "cm", "inch"),
                    multiple = FALSE
                  ),
                  shiny::numericInput(
                    inputId = "plot_measurement_value_as_numeric_download_dpi",
                    label = "dpi",
                    value = 300
                  ),
                  shiny::downloadButton(outputId = "plot_measurement_value_as_numeric_download", label = "Download")
                ),
                class = "text-end"
              ),
              bslib::layout_sidebar(
                sidebar = bslib::sidebar(width = 400, open = "closed",
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_value_as_numeric_x",
                                           label = "Horizontal axis",
                                           selected = c("unit_concept_name"),
                                           multiple = FALSE,
                                           choices = c("unit_concept_name", "codelist_name", "concept_name", "cdm_name"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_value_as_numeric_plottype",
                                           label = "Plot type",
                                           selected = "boxplot",
                                           multiple = FALSE,
                                           choices = c("boxplot", "densityplot"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_value_as_numeric_colour",
                                           label = "Colour",
                                           selected = c("cdm_name"),
                                           multiple = TRUE,
                                           choices = c("unit_concept_name", "codelist_name", "concept_name", "cdm_name"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_value_as_numeric_facet",
                                           label = "Facet",
                                           selected = c("codelist_name", "concept_name"),
                                           multiple = TRUE,
                                           choices = c("unit_concept_name", "codelist_name", "concept_name", "cdm_name"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         position = "right"
                ),
                shiny::plotOutput("plot_measurement_value_as_numeric")
              )
            )
          ),
          bslib::nav_panel(
            title = "Table Timings",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(
                shiny::downloadButton(outputId = "measurement_timings_gt_download", label = ""),
                class = "text-end"
              ),
              bslib::layout_sidebar(
                sidebar = bslib::sidebar(width = 400, open = "closed",
                                         sortable::bucket_list(
                                           header = "Table formatting",
                                           sortable::add_rank_list(
                                             text = "none",
                                             labels = c("cohort_name", "variable_name", "estimate_name"),
                                             input_id = "measurement_timings_gt_none"
                                           ),
                                           sortable::add_rank_list(
                                             text = "header",
                                             labels = c("cdm_name"),
                                             input_id = "measurement_timings_gt_header"
                                           ),
                                           sortable::add_rank_list(
                                             text = "groupColumn",
                                             labels =  c("codelist_name"),
                                             input_id = "measurement_timings_gt_groupColumn"
                                           ),
                                           sortable::add_rank_list(
                                             text = "hide",
                                             labels =  c("variable_level"),
                                             input_id = "measurement_timings_gt_hide"
                                           )
                                         ),
                                         position = "right"
                ),
                gt::gt_output("measurement_timings_tbl") |> withSpinner()
              )
            )
          ),
          bslib::nav_panel(
            title = "Plot timings",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(
                bslib::popover(
                  shiny::icon("download"),
                  shiny::numericInput(
                    inputId = "plot_measurement_timings_download_width",
                    label = "Width",
                    value = 15
                  ),
                  shiny::numericInput(
                    inputId = "plot_measurement_timings_download_height",
                    label = "Height",
                    value = 10
                  ),
                  shinyWidgets::pickerInput(
                    inputId = "plot_measurement_timings_download_units",
                    label = "Units",
                    selected = "cm",
                    choices = c("px", "cm", "inch"),
                    multiple = FALSE
                  ),
                  shiny::numericInput(
                    inputId = "plot_measurement_timings_download_dpi",
                    label = "dpi",
                    value = 300
                  ),
                  shiny::downloadButton(outputId = "plot_measurement_timings_download", label = "Download")
                ),
                class = "text-end"
              ),
              bslib::layout_sidebar(
                sidebar = bslib::sidebar(width = 400, open = "closed",
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_timings_y",
                                           label = "Vertical axis",
                                           selected = c("time"),
                                           multiple = FALSE,
                                           choices = c("time", "measurements_per_subject"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_timings_time_scale",
                                           label = "Time scale",
                                           selected = c("days"),
                                           multiple = FALSE,
                                           choices = c("days", "years"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_timings_plottype",
                                           label = "Plot type",
                                           selected = "boxplot",
                                           multiple = FALSE,
                                           choices = c("boxplot", "densityplot"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_timings_colour",
                                           label = "Colour",
                                           selected = c("codelist_name"),
                                           multiple = TRUE,
                                           choices = c("cdm_name", "codelist_name", "cohort_name"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         shinyWidgets::pickerInput(
                                           inputId = "measurement_timings_facet",
                                           label = "Facet",
                                           selected = c("cdm_name"),
                                           multiple = TRUE,
                                           choices = c("cdm_name", "codelist_name", "cohort_name"),
                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                         ),
                                         position = "right"
                ),
                shiny::plotOutput("plot_measurement_timings")
              )
            )
          )
        )
      )
      ## measurement_diagnostics_end
    ),
    # codelistDiagnostics_end ----
    # cohortDiagnostics_start -----
    bslib::nav_menu(
      title = "Cohort diagnostics",
      icon = shiny::icon("list"),
      ## Cohort count ----
      bslib::nav_panel(
        title = "Cohort count",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_cohort_count_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_name,
                    choices = choices$shared_cdm_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_cohort_count_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_name,
                    choices = choices$shared_cohort_name,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateCohortCount", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("person"),
        accordion(open = FALSE,
                  accordion_panel(
                    title = "Show cohort expectations",
                    value = "panel_ce_1",
                    reactable::reactableOutput("cohort_count_expectations")
                  )),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       div(style="display: flex; justify-content: space-between;",
                                           div(style="flex: 1;", prettyCheckbox(inputId = "cohort_count_person_count",
                                                                                label = "Person count",
                                                                                value = TRUE,
                                                                                status = "primary",
                                                                                shape = "curve",
                                                                                outline = TRUE)),
                                           div(style="flex: 1;", prettyCheckbox(inputId = "cohort_count_record_count",
                                                                                label = "Record count",
                                                                                value = TRUE,
                                                                                status = "primary",
                                                                                shape = "curve",
                                                                                outline = TRUE))
                                       )
                                     )
                                   )
          ),
          bslib::navset_card_tab(
            bslib::nav_panel(
              title = "Counts",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "summarise_cohort_count_gt_download", label = ""),
                  class = "text-end"
                ),
                gt::gt_output("summarise_cohort_count_gt") |> withSpinner()
              )
            ),
            bslib::nav_panel(
              title = "Attrition",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "summarise_cohort_attrition_gt_download", label = ""),
                  class = "text-end"
                ),
                gt::gt_output("summarise_cohort_attrition_gt") |> withSpinner()
              )
            ),
            bslib::nav_panel(
              title = "Flowchart",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  bslib::popover(
                    shiny::icon("download"),
                    shiny::numericInput(
                      inputId = "summarise_cohort_attrition_grViz_download_width",
                      label = "Width",
                      value = 15
                    ),
                    shiny::numericInput(
                      inputId = "summarise_cohort_attrition_grViz_download_height",
                      label = "Height",
                      value = 10
                    ),
                    shiny::downloadButton(outputId = "summarise_cohort_attrition_grViz_download", label = "Download")
                  ),
                  class = "text-end"
                ),
                DiagrammeR::grVizOutput("summarise_cohort_attrition_grViz") |> withSpinner()
              )
            )
          )
        )
      ),

      ## Cohort characteristics -----
      bslib::nav_panel(
        title = "Cohort characteristics",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_characteristics_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_names,
                    choices = choices$shared_cdm_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_characteristics_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_names,
                    choices = choices$shared_cohort_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateCohortCharacteristics", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("users-gear"),
        accordion(open = FALSE,
                  accordion_panel(
                    title = "Show cohort expectations",
                    value = "panel_ce_2",
                    reactable::reactableOutput("cohort_characteristics_expectations")
                  )),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::prettyCheckbox(
                                         inputId = "summarise_characteristics_include_matched",
                                         label = "Show matched cohorts",
                                         value = FALSE)
                                     )
                                   )
          ),
          bslib::navset_card_tab(
            bslib::nav_panel(
              title = "Table",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "summarise_characteristics_gt_download", label = ""),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           sortable::bucket_list(
                                             header = "Table formatting",
                                             sortable::add_rank_list(
                                               text = "none",
                                               labels = c("variable_name", "variable_level", "estimate_name"),
                                               input_id = "summarise_characteristics_gt_none"
                                             ),
                                             sortable::add_rank_list(
                                               text = "header",
                                               labels = c("cdm_name", "cohort_name"),
                                               input_id = "summarise_characteristics_gt_header"
                                             ),
                                             sortable::add_rank_list(
                                               text = "groupColumn",
                                               labels = NULL,
                                               input_id = "summarise_characteristics_gt_groupColumn"
                                             ),
                                             sortable::add_rank_list(
                                               text = "hide",
                                               labels = c("diagnostic", "phenotyper_version", "matchedSample"),
                                               input_id = "summarise_characteristics_gt_hide"
                                             )
                                           ),
                                           position = "right"
                  ),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgCohortSample),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgMatchedSample),
                  gt::gt_output("summarise_characteristics_gt") |> withSpinner()
                )
              )
            ),
            bslib::nav_panel(
              title = "Age distribution",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  bslib::popover(
                    shiny::icon("download"),
                    shiny::numericInput(
                      inputId = "plot_age_pyramid_download_width",
                      label = "Width",
                      value = 15
                    ),
                    shiny::numericInput(
                      inputId = "plot_age_pyramid_download_height",
                      label = "Height",
                      value = 10
                    ),
                    shinyWidgets::pickerInput(
                      inputId = "plot_age_pyramid_download_units",
                      label = "Units",
                      selected = "cm",
                      choices = c("px", "cm", "inch"),
                      multiple = FALSE
                    ),
                    shiny::numericInput(
                      inputId = "plot_age_pyramid_download_dpi",
                      label = "dpi",
                      value = 300
                    ),
                    shiny::downloadButton(outputId = "plot_age_pyramid_download", label = "Download")
                  ),
                  class = "text-end",
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           shiny::checkboxInput(
                                             inputId = "summarise_characteristics_add_interquantile_range",
                                             label = "Show interquantile range",
                                             value = c(TRUE)
                                           ),
                                           position = "right"
                  ),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgCohortSample),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgMatchedSample),
                  shiny::plotOutput("plot_age_pyramid")
                )
              )
            )
          )
        )
      ),

      ## Large scale characteristics -----
      bslib::nav_panel(
        title = "Large scale characteristics",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_large_scale_characteristics_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_names,
                    choices = choices$shared_cdm_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_large_scale_characteristics_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_names,
                    choices = choices$shared_cohort_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateLSC", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("arrow-up-right-dots"),
        accordion(open = FALSE,
                  accordion_panel(
                    title = "Show cohort expectations",
                    value = "panel_ce_3",
                    reactable::reactableOutput("large_scale_characteristics_expectations")
                  )),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "summarise_large_scale_characteristics_table_name",
                                         label = "Domain",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "summarise_large_scale_characteristics_variable_level",
                                         label = "Time window",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "summarise_large_scale_characteristics_analysis",
                                         label = "Analysis",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = FALSE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       )
                                     )
                                   )
          ),
          bslib::navset_card_tab(
            bslib::nav_panel(
              title = "All concepts",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "summarise_large_scale_characteristics_tidy_download", label = ""),,
                  class = "text-end"
                ),
                htmltools::tags$p(style = "font-size: 0.75em;", msgCohortSample),
                uiOutput("summarise_large_scale_characteristics_tidy") |> withSpinner()
              )
            ),
            bslib::nav_panel(
              title = "Top concepts",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "summarise_large_scale_characteristics_gt_download", label = ""),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           shiny::numericInput(
                                             min = 1,
                                             step = 1,
                                             inputId = "summarise_large_scale_characteristics_top_concepts",
                                             label = "Top concepts",
                                             value = 10
                                           ),
                                           position = "right"
                  ),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgCohortSample),
                  gt::gt_output("summarise_large_scale_characteristics_gt") |> withSpinner()
                )
              )
            )
          )
        )
      ),

      ## Compare large scale characteristics -----
      bslib::nav_panel(
        title = "Compare large scale characteristics",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "compare_large_scale_characteristics_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_names,
                    choices = choices$shared_cdm_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%",
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "compare_large_scale_characteristics_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_names,
                    choices = choices$shared_cohort_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateCompareLSC", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("people-arrows"),
        accordion(open = FALSE,
                  accordion_panel(
                    title = "Show cohort expectations",
                    value = "panel_ce_4",
                    reactable::reactableOutput("compare_large_scale_characteristics_expectations")
                  )),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "compare_large_scale_characteristics_cohort_compare",
                                         label = "Comparator cohort",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = FALSE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shiny::fluidRow(
                                         shiny::column(width = 5, offset = 1,
                                                       shinyWidgets::pickerInput(
                                                         inputId = "compare_large_scale_characteristics_cohort_1",
                                                         label = "Cohort type (reference)",
                                                         choices = NULL,
                                                         selected = NULL,
                                                         multiple = FALSE,
                                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                                       ),
                                                       tags$style(HTML("
                                                       label[for='compare_large_scale_characteristics_cohort_1'] {
                                                       text-align: center;
                                                       width: 100%;
                                                       display: block;
                                                       }"))
                                         ),
                                         shiny::column(width = 5,
                                                       shinyWidgets::pickerInput(
                                                         inputId = "compare_large_scale_characteristics_cohort_2",
                                                         label = "Cohort type (comparator)",
                                                         choices = NULL,
                                                         selected = NULL,
                                                         multiple = FALSE,
                                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                                       ),
                                                       tags$style(HTML("
                                                       label[for='compare_large_scale_characteristics_cohort_2'] {
                                                       text-align: center;
                                                       width: 100%;
                                                       display: block;
                                                       }"))
                                         )
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "compare_large_scale_characteristics_table_name",
                                         label = "Domain",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "compare_large_scale_characteristics_analysis",
                                         label = "Analysis",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = FALSE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "compare_large_scale_characteristics_variable_level",
                                         label = "Time window",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::prettyCheckbox(
                                         inputId = "compare_large_scale_characteristics_impute_missings",
                                         label = "Impute missing values as 0",
                                         value = TRUE)
                                     )
                                   )
          ),
          bslib::navset_card_tab(
            bslib::nav_panel(
              title = "Table",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "compare_large_scale_characteristics_tidy_download", label = ""),
                  class = "text-end"
                ),
                htmltools::tags$p(style = "font-size: 0.75em;", msgCohortSample),
                htmltools::tags$p(style = "font-size: 0.75em;", msgMatchedSample),
                reactable::reactableOutput("compare_large_scale_characteristics_tidy") |> withSpinner()
              )
            ),
            bslib::nav_panel(
              title = "Plot",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  bslib::popover(
                    shiny::icon("download"),
                    shiny::numericInput(
                      inputId = "plot_compare_large_scale_characteristics_download_width",
                      label = "Width",
                      value = 15
                    ),
                    shiny::numericInput(
                      inputId = "plot_compare_large_scale_characteristics_download_height",
                      label = "Height",
                      value = 10
                    ),
                    shinyWidgets::pickerInput(
                      inputId = "plot_compare_large_scale_characteristics_download_units",
                      label = "Units",
                      selected = "cm",
                      choices = c("px", "cm", "inch"),
                      multiple = FALSE
                    ),
                    shiny::numericInput(
                      inputId = "plot_compare_large_scale_characteristics_download_dpi",
                      label = "dpi",
                      value = 300
                    ),
                    shiny::downloadButton(outputId = "plot_compare_large_scale_characteristics_download", label = "Download")
                  ),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           shinyWidgets::pickerInput(
                                             inputId = "compare_large_scale_characteristics_colour_1",
                                             label = "Colour",
                                             selected = c("table"),
                                             multiple = TRUE,
                                             choices = c("table", "database", "time_window"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "compare_large_scale_characteristics_facet_1",
                                             label = "Facet",
                                             selected = c("database"),
                                             multiple = TRUE,
                                             choices = c("table", "database", "time_window"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           position = "right"
                  ),
                  position = "right",
                  htmltools::tags$p(style = "font-size: 0.75em;", msgCohortSample),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgMatchedSample),
                  plotly::plotlyOutput("plotly_compare_lsc") |> withSpinner()
                )
              )
            )
          )
        )
      ),

      ## Compare cohorts -----
      bslib::nav_panel(
        title = "Compare cohorts",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_cohort_overlap_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_names,
                    choices = choices$shared_cdm_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "summarise_cohort_overlap_cohort_name_reference",
                    label = NULL,
                    selected = selected$shared_cohort_names,
                    choices = choices$shared_cohort_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateCompareCohorts", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("yin-yang"),
        accordion(open = FALSE,
                  accordion_panel(
                    title = "Show cohort expectations",
                    value = "panel_ce_5",
                    reactable::reactableOutput("compare_cohorts_expectations")
                  )),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "summarise_cohort_overlap_cohort_comparator",
                                         label = "Cohort comparator",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       )
                                     )
                                   )
          ),
          bslib::navset_card_tab(
            bslib::nav_panel(
              title = "Cohort Overlap (Table)",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "summarise_cohort_overlap_gt_download", label = ""),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           shinyWidgets::pickerInput(
                                             inputId = "summarise_cohort_overlap_variable_name",
                                             label = "Variable name",
                                             choices = NULL,
                                             selected = NULL,
                                             multiple = TRUE,
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shiny::checkboxInput(
                                             inputId = "summarise_cohort_overlap_gt_uniqueCombinations",
                                             label = "uniqueCombinations",
                                             value = c(TRUE)
                                           ),
                                           sortable::bucket_list(
                                             header = "Table formatting",
                                             sortable::add_rank_list(
                                               text = "none",
                                               labels = c("cohort_name_reference", "cohort_name_comparator", "estimate_name"),
                                               input_id = "summarise_cohort_overlap_gt_none"
                                             ),
                                             sortable::add_rank_list(
                                               text = "header",
                                               labels = "variable_name",
                                               input_id = "summarise_cohort_overlap_gt_header"
                                             ),
                                             sortable::add_rank_list(
                                               text = "groupColumn",
                                               labels = "cdm_name",
                                               input_id = "summarise_cohort_overlap_gt_groupColumn"
                                             ),
                                             sortable::add_rank_list(
                                               text = "hide",
                                               labels = c("variable_level", "diagnostic", "phenotyper_version", "matchedSample"),
                                               input_id = "summarise_cohort_overlap_gt_hide"
                                             )
                                           ),
                                           position = "right"
                  ),
                  gt::gt_output("summarise_cohort_overlap_gt") |> withSpinner()
                )
              )
            ),
            bslib::nav_panel(
              title = "Cohort Overlap (Plot)",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  bslib::popover(
                    shiny::icon("download"),
                    shiny::numericInput(
                      inputId = "summarise_cohort_overlap_plot_download_width",
                      label = "Width",
                      value = 15
                    ),
                    shiny::numericInput(
                      inputId = "summarise_cohort_overlap_plot_download_height",
                      label = "Height",
                      value = 10
                    ),
                    shinyWidgets::pickerInput(
                      inputId = "summarise_cohort_overlap_plot_download_units",
                      label = "Units",
                      selected = "cm",
                      choices = c("px", "cm", "inch"),
                      multiple = FALSE
                    ),
                    shiny::numericInput(
                      inputId = "summarise_cohort_overlap_plot_download_dpi",
                      label = "dpi",
                      value = 300
                    ),
                    shiny::downloadButton(outputId = "summarise_cohort_overlap_plot_download", label = "Download")
                  ),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           shinyWidgets::pickerInput(
                                             inputId = "summarise_cohort_overlap_variable_name",
                                             label = "Variable name",
                                             choices = c("Only in reference cohort", "In both cohorts", "Only in comparator cohort"),
                                             selected = c("Only in reference cohort", "In both cohorts", "Only in comparator cohort"),
                                             multiple = TRUE,
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shiny::checkboxInput(
                                             inputId = "summarise_cohort_overlap_plot_uniqueCombinations",
                                             label = "uniqueCombinations",
                                             value = c(TRUE)
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "summarise_cohort_overlap_plot_colour",
                                             label = "Colour",
                                             selected = c("variable_name"),
                                             multiple = TRUE,
                                             choices = c("cdm_name", "cohort_name_reference", "cohort_name_comparator", "variable_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "summarise_cohort_overlap_plot_facet",
                                             label = "Facet",
                                             selected = c("cdm_name", "cohort_name_reference"),
                                             multiple = TRUE,
                                             choices = c("cdm_name", "cohort_name_reference", "cohort_name_comparator", "variable_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           position = "right"
                  ),
                  plotly::plotlyOutput("summarise_cohort_overlap_plot")
                )
              )
            ),
            bslib::nav_panel(
              title = "Cohort Timing (Table)",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "summarise_cohort_timing_gt_download", label = ""),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           shinyWidgets::pickerInput(
                                             inputId = "summarise_cohort_timing_gt_time_scale",
                                             label = "Time scale",
                                             choices = c("days", "years"),
                                             selected = "days",
                                             multiple = FALSE,
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shiny::checkboxInput(
                                             inputId = "summarise_cohort_timing_gt_uniqueCombinations",
                                             label = "uniqueCombinations",
                                             value = c(TRUE)
                                           ),
                                           sortable::bucket_list(
                                             header = "Table formatting",
                                             sortable::add_rank_list(
                                               text = "none",
                                               labels = c("cohort_name_reference", "cohort_name_comparator", "estimate_name"),
                                               input_id = "summarise_cohort_timing_gt_none"
                                             ),
                                             sortable::add_rank_list(
                                               text = "header",
                                               labels = "variable_name",
                                               input_id = "summarise_cohort_timing_gt_header"
                                             ),
                                             sortable::add_rank_list(
                                               text = "groupColumn",
                                               labels = "cdm_name",
                                               input_id = "summarise_cohort_timing_gt_groupColumn"
                                             ),
                                             sortable::add_rank_list(
                                               text = "hide",
                                               labels = "variable_level",
                                               input_id = "summarise_cohort_timing_gt_hide"
                                             )
                                           ),
                                           position = "right"
                  ),
                  gt::gt_output("summarise_cohort_timing_gt") |> withSpinner()
                )
              )
            ),
            bslib::nav_panel(
              title = "Cohort Timing (Plot)",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  bslib::popover(
                    shiny::icon("download"),
                    shiny::numericInput(
                      inputId = "summarise_cohort_timing_plot_download_width",
                      label = "Width",
                      value = 15
                    ),
                    shiny::numericInput(
                      inputId = "summarise_cohort_timing_plot_download_height",
                      label = "Height",
                      value = 10
                    ),
                    shinyWidgets::pickerInput(
                      inputId = "summarise_cohort_timing_plot_download_units",
                      label = "Units",
                      selected = "cm",
                      choices = c("px", "cm", "inch"),
                      multiple = FALSE
                    ),
                    shiny::numericInput(
                      inputId = "summarise_cohort_timing_plot_download_dpi",
                      label = "dpi",
                      value = 300
                    ),
                    shiny::downloadButton(outputId = "summarise_cohort_timing_plot_download", label = "Download")
                  ),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           shinyWidgets::pickerInput(
                                             inputId = "summarise_cohort_timing_plot_time_scale",
                                             label = "Time scale",
                                             choices = c("days", "years"),
                                             selected = "days",
                                             multiple = FALSE,
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shiny::checkboxInput(
                                             inputId = "summarise_cohort_timing_plot_uniqueCombinations",
                                             label = "uniqueCombinations",
                                             value = c(TRUE)
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "summarise_cohort_timing_plot_colour",
                                             label = "Colour",
                                             selected = c("cohort_name_comparator"),
                                             multiple = TRUE,
                                             choices = c("cdm_name", "cohort_name_reference", "cohort_name_comparator", "variable_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "summarise_cohort_timing_plot_facet",
                                             label = "Facet",
                                             selected = c("cdm_name", "cohort_name_reference"),
                                             multiple = TRUE,
                                             choices = c("cdm_name", "cohort_name_reference", "cohort_name_comparator", "variable_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           position = "right"
                  ),
                  plotly::plotlyOutput("summarise_cohort_timing_plot")
                )
              )
            )
          )
        )
      ),
      ## cohort_survival_start
      ## Cohort survival -----
      bslib::nav_panel(
        title = "Cohort survival",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "survival_probability_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_names,
                    choices = choices$shared_cdm_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "survival_probability_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_names,
                    choices = choices$shared_cohort_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateCohortSurvival", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("chart-gantt"),
        accordion(open = FALSE,
                  accordion_panel(
                    title = "Show cohort expectations",
                    value = "panel_ce_6",
                    reactable::reactableOutput("cohort_survival_expectations")
                  )),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shiny::checkboxInput(
                                         inputId = "survival_porbability_include_matches",
                                         label = "Show matched cohorts",
                                         value = c(TRUE)
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "survival_probability_time_scale",
                                         label = "Time scale",
                                         choices = c("days", "months", "years"),
                                         selected = "days",
                                         multiple = FALSE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       )
                                     )
                                   )
          ),
          bslib::navset_card_tab(
            bslib::nav_panel(
              title = "Table",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "summarise_cohort_survival_gt_download", label = ""),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           sortable::bucket_list(
                                             header = "Table formatting",
                                             sortable::add_rank_list(
                                               text = "none",
                                               labels = c("cdm_name", "target_cohort"),
                                               input_id = "survival_table_none"
                                             ),
                                             sortable::add_rank_list(
                                               text = "header",
                                               labels = "estimate_name",
                                               input_id = "survival_table_header"
                                             ),
                                             sortable::add_rank_list(
                                               text = "groupColumn",
                                               labels = character(),
                                               input_id = "survival_table_groupColumn"
                                             ),
                                             sortable::add_rank_list(
                                               text = "hide",
                                               labels = character(),
                                               input_id = "survival_table_hide"
                                             )
                                           ),
                                           position = "right"
                  ),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgCohortSample),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgMatchedSample),
                  gt::gt_output("summarise_cohort_survival_gt") |> withSpinner()
                )
              )
            ),
            bslib::nav_panel(
              title = "Plot",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  bslib::popover(
                    shiny::icon("download"),
                    shiny::numericInput(
                      inputId = "summarise_cohort_survival_plot_download_width",
                      label = "Width",
                      value = 15
                    ),
                    shiny::numericInput(
                      inputId = "summarise_cohort_survival_plot_download_height",
                      label = "Height",
                      value = 10
                    ),
                    shinyWidgets::pickerInput(
                      inputId = "summarise_cohort_survival_plot_download_units",
                      label = "Units",
                      selected = "cm",
                      choices = c("px", "cm", "inch"),
                      multiple = FALSE
                    ),
                    shiny::numericInput(
                      inputId = "summarise_cohort_survival_plot_download_dpi",
                      label = "dpi",
                      value = 300
                    ),
                    shiny::downloadButton(outputId = "summarise_cohort_survival_plot_download", label = "Download")
                  ),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           materialSwitch(inputId = "survival_plot_interactive",
                                                          value = TRUE,
                                                          label = "Interactive",
                                                          status = "primary"),
                                           shiny::checkboxInput(
                                             inputId = "survival_plot_ribbon",
                                             label = "Ribbon",
                                             value = c(TRUE)
                                           ),
                                           shiny::checkboxInput(
                                             inputId = "survival_plot_cf",
                                             label = "Plot cumulative failure",
                                             value = FALSE
                                           ),
                                           shiny::checkboxInput(
                                             inputId = "survival_plot_log_log",
                                             label = "Plot LogLog",
                                             value = FALSE
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "survival_plot_colour",
                                             label = "Colour",
                                             selected = c("target_cohort"),
                                             multiple = TRUE,
                                             choices = c("cdm_name", "target_cohort"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "survival_plot_facet",
                                             label = "Facet",
                                             selected = c("cdm_name"),
                                             multiple = TRUE,
                                             choices = c("cdm_name", "target_cohort"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           position = "right"
                  ),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgCohortSample),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgMatchedSample),
                  uiOutput("summarise_cohort_survival_plot") |> withSpinner()
                )
              )
            )
          )
        )
      )
      ## cohort_survival_end
    ),
    # cohortDiagnostics_end ----
    # populationDiagnostics_start -----
    bslib::nav_menu(
      title = "Population diagnostics",
      icon = shiny::icon("list"),
      ## Incidence -----
      bslib::nav_panel(
        title = "Incidence",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "incidence_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_names,
                    choices = choices$shared_cdm_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "incidence_outcome_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_names,
                    choices = choices$shared_cohort_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updateIncidence", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("shower"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "incidence_analysis_interval",
                                         label = "Time interval",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "incidence_denominator_age_group",
                                         label = "Denominator age group",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "incidence_denominator_sex",
                                         label = "Denominator sex",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "incidence_denominator_days_prior_observation",
                                         label = "Denominator days prior observation",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       )
                                     )
                                   )
          ),
          bslib::navset_card_tab(
            bslib::nav_panel(
              title = "Table incidence",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "incidence_gt_download", label = ""),
                  class = "text-end"
                ),
                htmltools::tags$p(style = "font-size: 0.75em;", msgPopulationDiag),
                gt::gt_output("incidence_gt") |> withSpinner()
              )
            ),
            bslib::nav_panel(
              title = "Plot incidence",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  bslib::popover(
                    shiny::icon("download"),
                    shiny::numericInput(
                      inputId = "incidence_plot_download_width",
                      label = "Width",
                      value = 15
                    ),
                    shiny::numericInput(
                      inputId = "incidence_plot_download_height",
                      label = "Height",
                      value = 10
                    ),
                    shinyWidgets::pickerInput(
                      inputId = "incidence_plot_download_units",
                      label = "Units",
                      selected = "cm",
                      choices = c("px", "cm", "inch"),
                      multiple = FALSE
                    ),
                    shiny::numericInput(
                      inputId = "incidence_plot_download_dpi",
                      label = "dpi",
                      value = 300
                    ),
                    shiny::downloadButton(outputId = "incidence_plot_download", label = "Download")
                  ),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           materialSwitch(inputId = "incidence_plot_interactive",
                                                          value = TRUE,
                                                          label = "Interactive",
                                                          status = "primary"),
                                           shinyWidgets::pickerInput(
                                             inputId = "incidence_plot_y",
                                             label = "Vertical axis",
                                             selected = "Incidence",
                                             multiple = FALSE,
                                             choices = c("Incidence", "Denominator count", "Denominator person years", "Outcome count"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "incidence_plot_x",
                                             label = "Horizontal axis",
                                             selected = "incidence_start_date",
                                             multiple = FALSE,
                                             choices = c("cdm_name",
                                                         "incidence_start_date",
                                                         "analysis_outcome_washout",
                                                         "denominator_age_group",
                                                         "denominator_sex",
                                                         "denominator_days_prior_observation",
                                                         "outcome_cohort_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "incidence_plot_facet",
                                             label = "Facet",
                                             selected = "cdm_name",
                                             multiple = TRUE,
                                             choices = c("cdm_name",
                                                         "incidence_start_date",
                                                         "analysis_outcome_washout",
                                                         "denominator_age_group",
                                                         "denominator_sex",
                                                         "denominator_days_prior_observation",
                                                         "outcome_cohort_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shiny::checkboxInput(
                                             inputId = "incidence_plot_facet_free",
                                             label = "Free scales",
                                             value = c(FALSE)
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "incidence_plot_colour",
                                             label = "Colour",
                                             selected = "outcome_cohort_name",
                                             multiple = TRUE,
                                             choices = c("cdm_name",
                                                         "incidence_start_date",
                                                         "analysis_outcome_washout",
                                                         "denominator_age_group",
                                                         "denominator_sex",
                                                         "denominator_days_prior_observation",
                                                         "outcome_cohort_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           position = "right"
                  ),
                  htmltools::tags$p(style = "font-size: 0.75em;", msgPopulationDiag),
                  uiOutput("incidence_plot") |> withSpinner()
                )
              )
            )
          )
        )
      ),
      ## Prevalence -----
      bslib::nav_panel(
        title = "Prevalence",
        bslib::accordion(
          bslib::accordion_panel(
            title = "Shared inputs",
            tags$div(
              style = "background-color: #750075; color: white; padding: 10px; font-weight: bold;  display: flex; flex-wrap: wrap; gap: 10px; gap: 10px; height: auto; align-items: center;",
              tags$label("Select Database(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "prevalence_cdm_name",
                    label = NULL,
                    selected = selected$shared_cdm_names,
                    choices = choices$shared_cdm_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$label("Select Cohort(s):"),
              tags$div(
                style = "width: 225px;",
                tags$div(
                  style = "margin-top: 15px;",
                  shinyWidgets::pickerInput(
                    inputId = "prevalence_outcome_cohort_name",
                    label = NULL,
                    selected = selected$shared_cohort_names,
                    choices = choices$shared_cohort_names,
                    multiple = TRUE,
                    options = list(`actions-box` = TRUE, `selected-text-format` = "count > 1",
                                   `deselect-all-text` = "None", `select-all-text` = "All"),
                    width = "100%"
                  )
                )
              ),
              tags$div(
                style = "width: 225px;",
                actionBttn("updatePrevalence", "Update",
                           style = "simple"),
                width = "100%"
              )
            )
          )),
        icon = shiny::icon("bath"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "prevalence_analysis_interval",
                                         label = "Time interval",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "prevalence_denominator_age_group",
                                         label = "Denominator age group",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "prevalence_denominator_sex",
                                         label = "Denominator sex",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "prevalence_denominator_days_prior_observation",
                                         label = "Denominator days prior observation",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       )
                                     )
                                   )
          ),
          bslib::navset_card_tab(
            bslib::nav_panel(
              title = "Table prevalence",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  shiny::downloadButton(outputId = "prevalence_gt_download", label = ""),
                  class = "text-end"
                ),
                htmltools::tags$p(style = "font-size: 0.75em;", gsub("Incidence", "Prevalence", msgPopulationDiag)),
                gt::gt_output("prevalence_gt") |> withSpinner()
              )
            ),
            bslib::nav_panel(
              title = "Plot prevalence",
              bslib::card(
                full_screen = TRUE,
                bslib::card_header(
                  bslib::popover(
                    shiny::icon("download"),
                    shiny::numericInput(
                      inputId = "prevalence_plot_download_width",
                      label = "Width",
                      value = 15
                    ),
                    shiny::numericInput(
                      inputId = "prevalence_plot_download_height",
                      label = "Height",
                      value = 10
                    ),
                    shinyWidgets::pickerInput(
                      inputId = "prevalence_plot_download_units",
                      label = "Units",
                      selected = "cm",
                      choices = c("px", "cm", "inch"),
                      multiple = FALSE
                    ),
                    shiny::numericInput(
                      inputId = "prevalence_plot_download_dpi",
                      label = "dpi",
                      value = 300
                    ),
                    shiny::downloadButton(outputId = "prevalence_plot_download", label = "Download")
                  ),
                  class = "text-end"
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(width = 400, open = "closed",
                                           materialSwitch(inputId = "prevalence_plot_interactive",
                                                          value = TRUE,
                                                          label = "Interactive",
                                                          status = "primary"),
                                           shinyWidgets::pickerInput(
                                             inputId = "prevalence_plot_y",
                                             label = "Vertical axis",
                                             selected = "Prevalence",
                                             multiple = FALSE,
                                             choices = c("Prevalence", "Denominator count", "Outcome count"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "prevalence_plot_x",
                                             label = "Horizontal axis",
                                             selected = "prevalence_start_date",
                                             multiple = FALSE,
                                             choices = c("cdm_name",
                                                         "prevalence_start_date",
                                                         "denominator_age_group",
                                                         "denominator_sex",
                                                         "denominator_days_prior_observation",
                                                         "outcome_cohort_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "prevalence_plot_facet",
                                             label = "Facet",
                                             selected = "cdm_name",
                                             multiple = TRUE,
                                             choices = c("cdm_name",
                                                         "prevalence_start_date",
                                                         "denominator_age_group",
                                                         "denominator_sex",
                                                         "denominator_days_prior_observation",
                                                         "outcome_cohort_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           shiny::checkboxInput(
                                             inputId = "prevalence_plot_facet_free",
                                             label = "Free scales",
                                             value = c(FALSE)
                                           ),
                                           shinyWidgets::pickerInput(
                                             inputId = "prevalence_plot_colour",
                                             label = "Colour",
                                             selected = "outcome_cohort_name",
                                             multiple = TRUE,
                                             choices = c("cdm_name",
                                                         "prevalence_start_date",
                                                         "denominator_age_group",
                                                         "denominator_sex",
                                                         "denominator_days_prior_observation",
                                                         "outcome_cohort_name"),
                                             options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                           ),
                                           position = "right"
                  ),
                  htmltools::tags$p(style = "font-size: 0.75em;", gsub("Incidence", "Prevalence", msgPopulationDiag)),
                  uiOutput("prevalence_plot") |> withSpinner()
                )
              )
            )
          )
        )
      )
    ),
    # populationDiagnostics_end ----
    nav_spacer(),
    tags$head(
      # custom styling so the table is shown in full
      tags$style(HTML("
    .log-popover-wide {
      max-width: 95vw !important;
    }

    @media (min-width: 800px) {
      .log-popover-wide {
        max-width: 800px !important;
      }
    }

    .log-popover-wide .popover-body {
      padding: 10px;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
    }
  "))
    ),
    bslib::nav_item(
      bslib::popover(
        icon("clipboard-list"),
        gt::gt_output("summarise_log_file_gt"),
        options = list(customClass = "log-popover-wide")
      )
    ),
    bslib::nav_item(
      bslib::popover(
        shiny::icon("circle-info"),
        shiny::tags$img(
          src = "phenotyper_logo.png",
          class = "logo-img",
          alt = "Logo",
          height = "auto",
          width = "30%",
          style = "float:right"
        ),
        "This shiny app was generated with ",
        shiny::a(
          "PhenotypeR",
          href = "https://github.com/OHDSI/PhenotypeR",
          target = "_blank"
        ),
        shiny::strong(phenotyper_version)
      )
    ),
    bslib::nav_item(
      bslib::popover(
        shiny::icon("download"),
        shiny::downloadButton(
          outputId = "download_raw",
          label = "Download raw data",
          icon = shiny::icon("download")
        )
      )
    )
  )
)
