from pathlib import Path
import requests
import bs4
import fire
import markdownify

BASE_URL: str = "https://adventofcode.com/2024/day/"


class ArticleConverter(markdownify.MarkdownConverter):
    pass


def article_html(day: int) -> str:
    url = f"{BASE_URL}{day}"
    html_text = requests.get(url).text
    return html_text


def article_md(day: int) -> str:
    html = article_html(day)
    soup = bs4.BeautifulSoup(html, "html.parser")
    article = soup.find("article")
    return ArticleConverter().convert("\n".join(map(str, article.contents)))


def download(day: int) -> None:
    out_dir = Path(__file__).parent.parent / "articles" / ("day-" + str(day))
    out_dir.mkdir(exist_ok=True)
    with open(out_dir / "article.md", "w") as f:
        f.write(article_md(day).strip() + "\n")


def main():
    fire.Fire(download)
