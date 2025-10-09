import re
import html
import urllib.parse
from pathlib import Path
from bs4 import BeautifulSoup

def clean_filename(title: str, used_names: set) -> str:
    """Clean conversation title to a safe filename and ensure uniqueness."""
    # Remove or replace unsafe characters for filenames
    # (Windows reserved: \ / : * ? " < > | and control characters)
    cleaned = re.sub(r'[\\/:*?"<>|]', "", title)
    cleaned = cleaned.strip()  # remove leading/trailing whitespace
    # Truncate if too long
    if len(cleaned) > 50:
        cleaned = cleaned[:50].rstrip()
    # Default name if empty after cleaning
    if not cleaned:
        cleaned = "Untitled Chat"
    # Avoid duplicate filenames
    original = cleaned
    count = 1
    while cleaned in used_names:
        # Append or increment a numeric suffix for duplicates
        cleaned = f"{original} ({count})"
        count += 1
        if len(cleaned) > 50:  # ensure suffixed name isn't overly long
            cleaned = cleaned[:50].rstrip()
    used_names.add(cleaned)
    return cleaned

def split_chat_html(input_html: Path, output_dir: Path):
    """Split the exported chat HTML into individual conversation files."""
    # Read and parse the HTML file
    content = input_html.read_text(encoding="utf-8", errors="ignore")
    soup = BeautifulSoup(content, "html.parser")
    body = soup.body
    if body is None:
        raise RuntimeError("No <body> found in HTML; the file may be malformed.")
    
    # Prepare output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    
    used_names = set()
    index_entries = []  # to collect index links (title and filename)
    conversation_divs = []

    # Find all top-level divisions in body (potential conversation containers)
    for element in body.find_all(recursive=False):
        # Identify a conversation container by presence of a heading (title)
        # We consider <h1>-<h6>; ChatGPT export titles are typically in <h4>
        if element.find(["h1", "h2", "h3", "h4", "h5", "h6"]):
            conversation_divs.append(element)
    if not conversation_divs:
        raise RuntimeError("No conversations found in the HTML file.")
    
    # Process each conversation thread
    for conv in conversation_divs:
        # Extract conversation title from the first heading tag
        heading = conv.find(["h1", "h2", "h3", "h4", "h5", "h6"])
        title_text = heading.get_text(separator=" ", strip=True) if heading else "Untitled Chat"
        filename_base = clean_filename(title_text, used_names)
        filename = filename_base + ".html"
        
        # Build full HTML content for this conversation
        # Include doctype, head, and body with the conversation segment
        html_title = html.escape(title_text, quote=False)
        convo_html = (
            "<!DOCTYPE html>\n<html>\n<head>\n"
            "  <meta charset=\"UTF-8\" />\n"
            f"  <title>{html_title}</title>\n"
            "</head>\n<body>\n"
            f"{str(conv)}\n"
            "</body>\n</html>"
        )
        # Write to file
        output_path = output_dir / filename
        output_path.write_text(convo_html, encoding="utf-8")
        
        # Record entry for index (use original title text for display)
        index_entries.append((title_text, filename))
    
    # (Optional) Create an index.html listing all conversations
    index_entries.sort(key=lambda x: x[0])  # sort alphabetically by title (optional)
    index_lines = ["<ul>"]
    for title, fname in index_entries:
        safe_href = urllib.parse.quote(fname)
        safe_title = html.escape(title, quote=False)
        index_lines.append(f'  <li><a href="{safe_href}">{safe_title}</a></li>')
    index_lines.append("</ul>")
    index_html_content = (
        "<!DOCTYPE html>\n<html>\n<head>\n"
        "  <meta charset=\"UTF-8\" />\n"
        "  <title>ChatGPT Conversations Index</title>\n"
        "</head>\n<body>\n"
        "  <h1>Conversation Index</h1>\n"
        f'  {"\n".join(index_lines)}\n'
        "</body>\n</html>"
    )
    (output_dir / "index.html").write_text(index_html_content, encoding="utf-8")

if __name__ == "__main__":
    import sys
    import argparse
    parser = argparse.ArgumentParser(description="Split a ChatGPT-exported chat.html into individual conversation HTML files.")
    parser.add_argument("input_html", help="Path to the ChatGPT chat.html export file")
    parser.add_argument("-o", "--output-dir", default=".", help="Output directory for individual chat files (default: current directory)")
    args = parser.parse_args()
    try:
        input_path = Path(args.input_html)
        output_path = Path(args.output_dir)
        split_chat_html(input_path, output_path)
        print(f"Successfully split '{input_path.name}' into individual conversations in '{output_path}'.")
        print("Index of conversations saved as 'index.html'.")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
