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
        fields = ['id', 'email', 'username', 'avatar', 'created_at']

    def get_avatar(self, obj):
        request = self.context.get('request')
        if obj.avatar and request:
            return request.build_absolute_uri(obj.avatar.url)
        return None

class RecipeSerializer(serializers.ModelSerializer):
    ingredients = IngredientSerializer(many=True, read_only=True)
    category = CategorySerializer(read_only=True)
    created_by = UserSerializer(read_only=True)
    nutrition = NutritionSerializer(read_only=True) 
    # steps = CookingStepSerializer(many=True, read_only=True)
    nutrition = NutritionSerializer(read_only=True) # хэрэв Nutrition нь OneToOneField байвал

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
            'created_at'
        ]

class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ("id", "email", "username", "password", "avatar")

    def create(self, validated_data):
        password = validated_data.pop("password")
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class WishlistSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    recipe = RecipeSerializer(read_only=True)
    class Meta:
        model = Wishlist
        fields = "__all__"

