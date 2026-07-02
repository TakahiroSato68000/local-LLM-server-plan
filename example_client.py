#!/usr/bin/env python3
"""
ローカルLLMサーバ クライアントサンプル
OpenAI互換エンドポイント（/v1/chat/completions）を使用します。

使い方:
    pip install openai
    python example_client.py
"""

from openai import OpenAI

# Ollamaのローカルエンドポイントを指定
client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama",  # Ollamaはキー不要だが、ライブラリの仕様上必要
)

MODEL = "llama3"


def chat(messages: list[dict]) -> str:
    """メッセージリストを送信してアシスタントの返答を返す。"""
    response = client.chat.completions.create(
        model=MODEL,
        messages=messages,
    )
    return response.choices[0].message.content


def main() -> None:
    print(f"=== ローカルLLMチャット（モデル: {MODEL}）===")
    print("終了するには 'exit' または 'quit' を入力してください。\n")

    conversation: list[dict] = []

    while True:
        user_input = input("あなた: ").strip()
        if not user_input:
            continue
        if user_input.lower() in ("exit", "quit"):
            print("終了します。")
            break

        conversation.append({"role": "user", "content": user_input})

        try:
            reply = chat(conversation)
        except Exception as e:
            print(f"エラー: {e}")
            print("サーバが起動しているか確認してください: ollama serve")
            break

        conversation.append({"role": "assistant", "content": reply})
        print(f"アシスタント: {reply}\n")


if __name__ == "__main__":
    main()
