/*
 * package controller;
 * 
 * import org.springframework.web.bind.annotation.GetMapping; import
 * org.springframework.web.bind.annotation.RequestParam; import
 * org.springframework.web.bind.annotation.RestController;
 * 
 * import dto.PageCriteria; import dto.PageResult; import
 * lombok.RequiredArgsConstructor; import model.Book; import
 * service.BookService;
 * 
 * @RestController // JSON 반 api쓸날을 기대하며
 * 
 * @RequiredArgsConstructor public class BookApiController {
 * 
 * private final BookService bookService;
 * 
 * @GetMapping("/api/books") public PageResult<Book> list(@RequestParam Integer
 * page,
 * 
 * @RequestParam Integer size) { return bookService.getBooks(new
 * PageCriteria(page, size)); } }
 */