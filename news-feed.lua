local json = require('json')

_0RBIT = "BaMK1dfayo75s3q1ow6AO64UDpD9SEFbeE8xYrY2fyQ"
_0RBT_POINTS = "BUhZLMwQ6yZHguLtJYA5lLUa9LQzLXMXRfaq9FVcPJc"
BASE_URL = "https://saurav.tech/NewsAPI/top-headlines/category/health/in.json"
FEE_AMOUNT = "1000000000000"
NEWS = NEWS or {
    
}

function fetchNews()
    Send({
        Target = _0RBT_POINTS,
        Action = "Transfer",
        Recipient = _0RBIT,
        Quantity = FEE_AMOUNT,
        ["X-Url"] = BASE_URL,
        ["X-Action"] = "Get-Real-Data"
    })
    print(Colors.green .. "GET request sent to the 0rbit Process")
end

function recieveData(msg)
    local res = json.decode(msg.Data)
    local article
    local articles
    if res.status == "ok" then 
        articles = res.articles
        for k,v in pairs(articles) do
            article = 
            {
                title = v.title,
                description = v.description,
                url = v.url
            }
            table.insert(NEWS, article)
        end
        print("News Updated")
    else
        print("Unable to fetch news")
    end
end

function getNews(msg)
    local news = json.encode(NEWS)
    Handlers.utils.reply(news)(msg)
end

Handlers.add(
    "GetNews",
    Handlers.utils.hasMatchingTag("Action", "GetNews"),
    getNews
)

Handlers.add(
    "ReceiveData",
    Handlers.utils.hasMatchingTag("Action", "ReceiveData"),
    recieveData
)

Handlers.add(
    "FetchNews",
    Handlers.utils.hasMatchingTag("Action", "FetchNews"),
    fetchNews
)