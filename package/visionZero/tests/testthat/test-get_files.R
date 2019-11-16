a <- list.dirs(get_data_dir(),
               full.names = F,
               recursive = F)



test_that("get_data_dir works", {
  expect_equal(a,
               c("data",
                 "metadata"))
})

test_that("load_crash_data works", {
  expect_equal(class(load_crash_data())[[1]],
               "data.table")
})

test_that("load_person_data works", {
  expect_equal(class(load_person_data())[[1]],
               "data.table")
})

test_that("load_vehicle_data works", {
  expect_equal(class(load_vehicle_data())[[1]],
               "data.table")
})
