
ui <- fluidPage(
  bslib::page_navbar(
    theme = bs_theme(5, "pulse"), 
    navbar_options =list(class = "bg-dark", theme = "dark"),
    
    
    tags$style(HTML("
    #shared_cdm_names-label + .dropdown.bootstrap-select .dropdown-menu.inner {
       font-size: 14px !important;
       padding-left: 0px !important
    }
      
    #shared_cdm_names-label + .dropdown.bootstrap-select .dropdown-menu {
        min-height: 300px !important;
        overflow: auto !important;
        background-color: #ECEBF0 !important
    }
    
    #shared_cdm_names-label + .dropdown.bootstrap-select .dropdown-menu.inner li.selected span.text {
        font-weight: bold !important; 
    }
       
    #shared_cohort_names-label + .dropdown.bootstrap-select .dropdown-menu.inner {
       font-size: 14px !important;
       padding-left: 0px !important
    }
                    
    #shared_cohort_names-label + .dropdown.bootstrap-select .dropdown-menu {
        min-height: 300px !important;
        overflow: auto !important;
        background-color: #ECEBF0 !important
    }
    
    #shared_cohort_names-label + .dropdown.bootstrap-select .dropdown-menu.inner li.selected span.text {
        font-weight: bold !important; 
        color: 
    }
    ")),
    
    title = "PhenotypeR",
    
    bslib::nav_panel(title = "Background",
                     icon = shiny::icon("disease"),
                     shiny::includeMarkdown(path = "background.md")),
    
    # Database diagnostics -----
    bslib::nav_menu(
      title = "Database diagnostics",
      icon = shiny::icon("list"),
      ## snapshot -----
      bslib::nav_panel(
        title = "Snapshot",
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
      
      # Database diagnostics -----
      bslib::nav_menu(
        title = "Database diagnostics",
        icon = shiny::icon("list"),
        ## snapshot -----
        bslib::nav_panel(
          title = "Snapshot",
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
      # Codelist diagnostics -----
      bslib::nav_menu(
        title = "Codelist diagnostics",
        icon = shiny::icon("list"),
        ## achilles code use -----
        bslib::nav_panel(
          title = "Achilles code use",
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
        ## Cohort code use -----
        bslib::nav_panel(
          title = "Cohort code use",
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
                                             labels = c("cohort_name", "codelist_name", "source_concept_name", "source_concept_id", "domain_id", "variable_name", "variable_level"),
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
                                             labels = character(),
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
        )
      ),
      # Cohort diagnostics -----
      bslib::nav_menu(
        title = "Cohort diagnostics",
        icon = shiny::icon("list"),
        ## Cohort count ----
        bslib::nav_panel(
          title = "Cohort count",
          icon = shiny::icon("person"),
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
          icon = shiny::icon("users-gear"),
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
                                                 labels = character(),
                                                 input_id = "summarise_characteristics_gt_hide"
                                               )
                                             ),
                                             position = "right"
                    ),
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
                    class = "text-end"
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
          icon = shiny::icon("arrow-up-right-dots"),
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
                    shiny::downloadButton(outputId = "summarise_large_scale_characteristics_tidy_download", label = ""),
                    class = "text-end"
                  ),
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
          icon = shiny::icon("people-arrows"),
          bslib::layout_sidebar(
            sidebar = bslib::sidebar(width = 400, open = "closed",
                                     bslib::accordion(
                                       bslib::accordion_panel(
                                         title = "Settings",
                                         shiny::fluidRow(
                                           shiny::column(width = 6,
                                                         shinyWidgets::pickerInput(
                                                           inputId = "compare_large_scale_characteristics_cohort_name_1",
                                                           label = "Cohort 1",
                                                           choices = NULL,
                                                           selected = NULL,
                                                           multiple = FALSE,
                                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                                         )
                                           ),
                                           shiny::column(width = 6,
                                                         shinyWidgets::pickerInput(
                                                           inputId = "compare_large_scale_characteristics_cohort_name_2",
                                                           label = "Cohort 2",
                                                           choices = NULL,
                                                           selected = NULL,
                                                           multiple = FALSE,
                                                           options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                                         )
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
                    plotly::plotlyOutput("plotly_compare_lsc") |> withSpinner()
                  )
                )
              )
            )
          )
        ),
        ## Cohort overlap -----
        bslib::nav_panel(
          title = "Compare cohorts",
          icon = shiny::icon("yin-yang"),
          bslib::layout_sidebar(
            sidebar = bslib::sidebar(width = 400, open = "closed",
                                     bslib::accordion(
                                       bslib::accordion_panel(
                                         title = "Settings",
                                         shinyWidgets::pickerInput(
                                           inputId = "summarise_cohort_overlap_cohort_name_comparator",
                                           label = "Cohort name comparator",
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
                                                 labels = "variable_level",
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
        )
      ),
      # Population diagnostics -----
      bslib::nav_menu(
        title = "Population diagnostics",
        icon = shiny::icon("list"),
        ## Incidence -----
        bslib::nav_panel(
          title = "Incidence",
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
                    uiOutput("prevalence_plot") |> withSpinner()
                  )
                )
              )
            )
          )
        )
      ),
      ## Compare cohorts -----
      bslib::nav_panel(
        title = "Compare cohorts",
        icon = shiny::icon("yin-yang"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "summarise_cohort_overlap_cdm_name",
                                         label = "CDM name",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "summarise_cohort_overlap_cohort_name_reference",
                                         label = "Cohort name reference",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "summarise_cohort_overlap_cohort_name_comparator",
                                         label = "Cohort name comparator",
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
                                               labels = "variable_level",
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
                                             label = "Unique combinations",
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
      ## Cohort survival -----
      bslib::nav_panel(
        title = "Cohort survival",
        icon = shiny::icon("chart-gantt"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "survival_probability_cdm_name",
                                         label = "CDM name",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "survival_probability_target_cohort",
                                         label = "Cohort name",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
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
                  uiOutput("summarise_cohort_survival_plot") |> withSpinner()
                )
              )
            )
          )
        )
      )
    ),
    # Population diagnostics -----
    bslib::nav_menu(
      title = "Population diagnostics",
      icon = shiny::icon("list"),
      ## Incidence -----
      bslib::nav_panel(
        title = "Incidence",
        icon = shiny::icon("shower"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(width = 400, open = "closed",
                                   bslib::accordion(
                                     bslib::accordion_panel(
                                       title = "Settings",
                                       shinyWidgets::pickerInput(
                                         inputId = "incidence_cdm_name",
                                         label = "CDM name",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
                                       shinyWidgets::pickerInput(
                                         inputId = "incidence_outcome_cohort_name",
                                         label = "Outcome cohort name",
                                         choices = NULL,
                                         selected = NULL,
                                         multiple = TRUE,
                                         options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = "count > 3")
                                       ),
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
                  uiOutput("incidence_plot") |> withSpinner()
                )
              )
            )
          )
        )
      ),
      # end ------
      bslib::nav_spacer(),
      nav_item(
        shinyWidgets::pickerInput(
          inputId = "shared_cdm_names",
          label = "Select Database(s):",
          selected = selected$shared_cdm_names,
          choices = choices$shared_cdm_names,
          multiple = TRUE,
          options = list(`actions-box` = TRUE,`selected-text-format` = "count > 1",
                         `deselect-all-text` = "None", `select-all-text` = "All", 
                         size = 10),
          width = "fit"
        )
      ),
      nav_item(
        shinyWidgets::pickerInput(
          inputId = "shared_cohort_names",
          label = "Select Cohort(s):",
          selected = selected$shared_cohort_names,
          choices = choices$shared_cohort_names,
          multiple = TRUE,
          options = list(`actions-box` = TRUE,`selected-text-format` = "count > 1",
                         `deselect-all-text` = "None", `select-all-text` = "All"),
          width = "fit")
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