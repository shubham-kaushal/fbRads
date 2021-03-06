#' Create a copy of a campaign. You can copy a maximum of 3 entities between campaign, ad sets and ads.
#' @inheritParams fbad_request
#' @inheritParams fbad_copy_ad
#' @inheritParams fbad_copy_adset
#' @export
#' @references \url{https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/copies/}
fbad_copy_campaign <- function(fbacc,
                               campaign_id,
                               start_time = NULL,
                               end_time = NULL,
                               deep_copy = NULL,
                               status_option = NULL,
                               rename_strategy = NULL,
                               rename_prefix = NULL,
                               rename_suffix = NULL, ...) {

    fbacc <- fbad_check_fbacc()

    # campaign id missing
    if (missing(campaign_id)) {
        stop('Argument missing. A campaign id is required.')
    }

    # check if campaign id actually exists
    list_of_campaigns <- fbad_list_campaign(fbacc)

    if(!campaign_id %in% list_of_campaigns$id) {
        stop('This campaign id does not exists. Please provide a valid campaign id.')
    }

    # rename options
    if(is.null(rename_strategy) & !is.null(rename_prefix)) {
        stop("You have not selected a rename_strategy, therefore, you should not select arguments rename_prefix")
    } else if(is.null(rename_strategy) & !is.null(rename_suffix)) {
        stop("You have not selected a rename_strategy, therefore, you should not select arguments rename_suffix")
    } else if(is.null(rename_strategy) & !is.null(rename_suffix) & !is.null(rename_prefix)) {
        stop("You have not selected a rename_strategy, therefore, you should not select arguments rename_suffix or rename_prefix")
    } else if(is.null(rename_strategy) & is.null(rename_prefix) & is.null(rename_suffix)) {
        rename_options <- NULL
    } else if(rename_strategy == "NO_RENAME" & (!is.null(rename_prefix) | !is.null(rename_suffix))) {
        stop("Your rename_stratey is 'NO_RENAME', therefore, you should not select arguments rename_prefix or rename_suffix")
    } else if((rename_strategy == "DEEP_RENAME" | rename_strategy == "ONLY_TOP_LEVEL_RENAME") & is.null(rename_prefix) & is.null(rename_suffix)) {
        stop("You have selected 'DEEP_RENAME' or 'ONLY_TOP_LEVEL_RENAME' as the argument rename_strategy. You need to specify either the rename_prefix argument, the rename_suffix argument or both")
    } else if(!is.null(rename_strategy) & !is.null(rename_prefix) & !is.null(rename_suffix)) {
        rename_options <- list(rename_strategy = rename_strategy,
                               rename_prefix = rename_prefix,
                               rename_suffix = rename_suffix)
    } else if(!is.null(rename_strategy) & !is.null(rename_prefix)) {
        rename_options <- list(rename_strategy = rename_strategy,
                               rename_prefix = rename_prefix)
    } else if(!is.null(rename_strategy) & !is.null(rename_suffix)) {
        rename_options <- list(rename_strategy = rename_strategy,
                               rename_suffix = rename_suffix)
    } else if(!is.null(rename_strategy) & is.null(rename_prefix) & is.null(rename_suffix)) {
        rename_options <- list(rename_strategy = rename_strategy)
    }

    ## build params list
    params <- list(
        start_time = start_time,
        end_time = end_time,
        deep_copy = deep_copy,
        status_option = status_option,
        rename_options = rename_options)

    ## transform lists to JSON
    params$rename_options <- toJSON(rename_options, auto_unbox = TRUE)

    ## drop NULL args
    params <- as.list(unlist(params, recursive = FALSE))

    # post request to copy adset
    fbad_request(fbacc,
                 path   = paste0(campaign_id, "/copies?access_token=", fbacc$access_token),
                 method = "POST",
                 params = params)

}
