from rest_framework import serializers
from .models import *

class IngredientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ingredient
        fields = ['id', 'name']


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name']


class NutritionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Nutrition
        fields = ['id', 'calories', 'protein', 'fat', 'carbs']


class UserSerializer(serializers.ModelSerializer):
    avatar = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ["id", "email", "username", "avatar", "created_at"]

    def get_avatar(self, obj):
        request = self.context.get("request")
        if obj.avatar and request:
            return request.build_absolute_uri(obj.avatar.url)
        return None


class RecipeSerializer(serializers.ModelSerializer):
    category = serializers.PrimaryKeyRelatedField(queryset=Category.objects.all())
    ingredients = serializers.PrimaryKeyRelatedField(
        queryset=Ingredient.objects.all(), many=True
    )
    nutrition = NutritionSerializer(required=False)
    created_by = UserSerializer(read_only=True)

    average_rating = serializers.FloatField(
        source='avg_rating', read_only=True
    )

    class Meta:
        model = Recipe
        fields = [
            'id',
            'name',
            'description',
            'image',
            'time_required',
            'servings',
            'cuisine',
            'category',
            'ingredients',
            'nutrition',
            'created_by',
            'created_at',
            'average_rating',
        ]


    def create(self, validated_data):
        nutrition_data = validated_data.pop("nutrition", None)
        ingredients = validated_data.pop("ingredients")

        recipe = Recipe.objects.create(**validated_data)
        recipe.ingredients.set(ingredients)

        if nutrition_data:
            Nutrition.objects.create(recipe=recipe, **nutrition_data)

        return recipe

    def get_average_rating(self, obj):
        ratings = obj.ratings.all()
        if ratings.exists():
            return round(sum(r.rating for r in ratings) / ratings.count(), 1)
        return 0


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    avatar = serializers.ImageField(required=False)

    class Meta:
        model = User
        fields = ("id", "email", "username", "password", "avatar")

    def create(self, validated_data):
        password = validated_data.pop("password")
        avatar = validated_data.pop("avatar", None)

        user = User.objects.create_user(
            email=validated_data["email"],
            username=validated_data["username"],
            password=password,
        )

        if avatar:
            user.avatar = avatar
            user.save()

        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    avatar = serializers.ImageField(required=False)
    remove_avatar = serializers.BooleanField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ("email", "username", "avatar", "remove_avatar")


class WishlistSerializer(serializers.ModelSerializer):
    recipe = RecipeSerializer(read_only=True)

    class Meta:
        model = Wishlist
        fields = "__all__"


class RecipeRatingSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = RecipeRating
        fields = ["id", "user", "recipe", "rating"]
